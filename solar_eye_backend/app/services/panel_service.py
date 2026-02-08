"""
Solar Eye Backend - Panel Service

패널 관련 비즈니스 로직
"""

import logging
import re
from datetime import datetime, date
from typing import Optional, Tuple

from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis

from app.models.panel import Panel, PanelStatus
from app.models.detection import Detection
from app.schemas.panel import PanelCreate, PanelUpdate

logger = logging.getLogger(__name__)

# Redis 캐시 키 패턴
PANEL_STATUS_KEY = "panel:status:{panel_id}"
PANEL_STATUS_TTL = 60  # 60초


class PanelService:
    """패널 서비스 클래스"""

    def __init__(self, db: AsyncSession, redis: Optional[Redis] = None):
        self.db = db
        self.redis = redis

    async def create_panel(self, user_id: int, data: PanelCreate) -> Panel:
        """
        패널 등록
        
        Args:
            user_id: 소유자 ID
            data: 패널 생성 데이터
        """
        # RTSP URL 유효성 검증
        if data.rtsp_url:
            self._validate_rtsp_url(data.rtsp_url)
        
        panel = Panel(
            user_id=user_id,
            name=data.name,
            description=data.description,
            location=data.location,
            rtsp_url=data.rtsp_url,
            latitude=data.latitude,
            longitude=data.longitude,
            capacity_kw=data.capacity_kw,
            panel_count=data.panel_count,
            status=PanelStatus.INACTIVE.value,
        )
        
        # 위경도가 있으면 기상청 격자 좌표 계산
        if data.latitude and data.longitude:
            grid_x, grid_y = self._convert_to_grid(data.latitude, data.longitude)
            panel.grid_nx = grid_x
            panel.grid_ny = grid_y
        
        self.db.add(panel)
        await self.db.commit()
        await self.db.refresh(panel)
        
        logger.info(f"Panel created: {panel.id} - {panel.name}")
        return panel

    async def get_panel(self, panel_id: int, user_id: int) -> Optional[Panel]:
        """패널 상세 조회 (소유자 확인)"""
        result = await self.db.execute(
            select(Panel).where(
                and_(Panel.id == panel_id, Panel.user_id == user_id)
            )
        )
        return result.scalar_one_or_none()

    async def get_panels(
        self,
        user_id: int,
        status: Optional[str] = None,
        search: Optional[str] = None,
        offset: int = 0,
        limit: int = 20,
    ) -> Tuple[list[Panel], int]:
        """
        패널 목록 조회 (페이지네이션)
        
        Returns:
            (패널 목록, 전체 개수)
        """
        # 기본 쿼리
        query = select(Panel).where(Panel.user_id == user_id)
        count_query = select(func.count(Panel.id)).where(Panel.user_id == user_id)
        
        # 상태 필터
        if status:
            query = query.where(Panel.status == status)
            count_query = count_query.where(Panel.status == status)
        
        # 검색 필터
        if search:
            search_filter = Panel.name.ilike(f"%{search}%") | Panel.location.ilike(f"%{search}%")
            query = query.where(search_filter)
            count_query = count_query.where(search_filter)
        
        # 정렬 및 페이지네이션
        query = query.order_by(Panel.created_at.desc()).offset(offset).limit(limit)
        
        # 실행
        result = await self.db.execute(query)
        panels = result.scalars().all()
        
        count_result = await self.db.execute(count_query)
        total = count_result.scalar() or 0
        
        return list(panels), total

    async def update_panel(
        self,
        panel: Panel,
        data: PanelUpdate,
    ) -> Panel:
        """패널 정보 수정"""
        update_data = data.model_dump(exclude_unset=True)
        
        # RTSP URL 유효성 검증
        if "rtsp_url" in update_data and update_data["rtsp_url"]:
            self._validate_rtsp_url(update_data["rtsp_url"])
        
        for field, value in update_data.items():
            setattr(panel, field, value)
        
        # 위경도 변경 시 격자 좌표 재계산
        if "latitude" in update_data or "longitude" in update_data:
            if panel.latitude and panel.longitude:
                grid_x, grid_y = self._convert_to_grid(panel.latitude, panel.longitude)
                panel.grid_nx = grid_x
                panel.grid_ny = grid_y
        
        await self.db.commit()
        await self.db.refresh(panel)
        
        # 캐시 무효화
        if self.redis:
            await self.redis.delete(PANEL_STATUS_KEY.format(panel_id=panel.id))
        
        logger.info(f"Panel updated: {panel.id}")
        return panel

    async def delete_panel(self, panel: Panel) -> None:
        """패널 삭제"""
        panel_id = panel.id
        await self.db.delete(panel)
        await self.db.commit()
        
        # 캐시 무효화
        if self.redis:
            await self.redis.delete(PANEL_STATUS_KEY.format(panel_id=panel_id))
        
        logger.info(f"Panel deleted: {panel_id}")

    async def get_panel_status(self, panel: Panel) -> dict:
        """
        패널 실시간 상태 조회 (Redis 캐시)
        """
        cache_key = PANEL_STATUS_KEY.format(panel_id=panel.id)
        
        # 캐시 확인
        if self.redis:
            cached = await self.redis.hgetall(cache_key)
            if cached:
                return {
                    "panel_id": panel.id,
                    "status": cached.get(b"status", b"").decode(),
                    "is_streaming": cached.get(b"is_streaming", b"0") == b"1",
                    "last_detection_at": cached.get(b"last_detection_at", b"").decode() or None,
                    "today_defects": int(cached.get(b"today_defects", b"0")),
                    "today_soiling": int(cached.get(b"today_soiling", b"0")),
                }
        
        # DB에서 오늘의 탐지 통계 조회
        today = date.today()
        stats = await self._get_today_detection_stats(panel.id, today)
        
        status_data = {
            "panel_id": panel.id,
            "status": panel.status,
            "is_streaming": panel.status == PanelStatus.ACTIVE.value,
            "last_detection_at": stats.get("last_detection_at"),
            "today_defects": stats.get("defect_count", 0),
            "today_soiling": stats.get("soiling_count", 0),
        }
        
        # 캐시 저장
        if self.redis:
            await self.redis.hset(cache_key, mapping={
                "status": status_data["status"],
                "is_streaming": "1" if status_data["is_streaming"] else "0",
                "last_detection_at": str(status_data["last_detection_at"] or ""),
                "today_defects": str(status_data["today_defects"]),
                "today_soiling": str(status_data["today_soiling"]),
            })
            await self.redis.expire(cache_key, PANEL_STATUS_TTL)
        
        return status_data

    async def _get_today_detection_stats(self, panel_id: int, today: date) -> dict:
        """오늘의 탐지 통계 조회"""
        result = await self.db.execute(
            select(
                func.count(Detection.id).filter(Detection.defect_type == "defect").label("defect_count"),
                func.count(Detection.id).filter(Detection.defect_type == "soiling").label("soiling_count"),
                func.max(Detection.detected_at).label("last_detection_at"),
            ).where(
                and_(
                    Detection.panel_id == panel_id,
                    func.date(Detection.detected_at) == today,
                )
            )
        )
        row = result.one()
        return {
            "defect_count": row.defect_count or 0,
            "soiling_count": row.soiling_count or 0,
            "last_detection_at": row.last_detection_at,
        }

    def _validate_rtsp_url(self, url: str) -> None:
        """RTSP URL 유효성 검증"""
        pattern = r"^rtsps?://[^\s]+$"
        if not re.match(pattern, url):
            raise ValueError("올바른 RTSP URL 형식이 아닙니다 (rtsp:// 또는 rtsps://)")

    def _convert_to_grid(self, lat: float, lon: float) -> Tuple[int, int]:
        """
        위경도 → 기상청 격자 좌표 변환
        (간소화된 버전 - 실제 구현 시 정확한 변환 공식 필요)
        """
        # 기상청 격자 좌표 변환 (Lambert Conformal Conic)
        RE = 6371.00877
        GRID = 5.0
        SLAT1 = 30.0
        SLAT2 = 60.0
        OLON = 126.0
        OLAT = 38.0
        XO = 43
        YO = 136
        
        import math
        
        DEGRAD = math.pi / 180.0
        
        re = RE / GRID
        slat1 = SLAT1 * DEGRAD
        slat2 = SLAT2 * DEGRAD
        olon = OLON * DEGRAD
        olat = OLAT * DEGRAD
        
        sn = math.tan(math.pi * 0.25 + slat2 * 0.5) / math.tan(math.pi * 0.25 + slat1 * 0.5)
        sn = math.log(math.cos(slat1) / math.cos(slat2)) / math.log(sn)
        sf = math.tan(math.pi * 0.25 + slat1 * 0.5)
        sf = math.pow(sf, sn) * math.cos(slat1) / sn
        ro = math.tan(math.pi * 0.25 + olat * 0.5)
        ro = re * sf / math.pow(ro, sn)
        
        ra = math.tan(math.pi * 0.25 + lat * DEGRAD * 0.5)
        ra = re * sf / math.pow(ra, sn)
        theta = lon * DEGRAD - olon
        if theta > math.pi:
            theta -= 2.0 * math.pi
        if theta < -math.pi:
            theta += 2.0 * math.pi
        theta *= sn
        
        x = int(ra * math.sin(theta) + XO + 0.5)
        y = int(ro - ra * math.cos(theta) + YO + 0.5)
        
        return x, y
