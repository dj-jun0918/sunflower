"""
Solar Eye Backend - Detection Service

탐지 결과 관련 비즈니스 로직
"""

import logging
from datetime import date, datetime, timedelta
from typing import Optional, Tuple

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.detection import Detection
from app.models.panel import Panel
from app.schemas.detection import (
    DetectionCreate,
    DetectionFilter,
    DetectionStats,
)

logger = logging.getLogger(__name__)


class DetectionService:
    """탐지 서비스 클래스"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_detection(
        self,
        data: DetectionCreate,
    ) -> Detection:
        """
        탐지 결과 저장

        Args:
            data: 탐지 결과 생성 데이터

        Returns:
            생성된 Detection 객체
        """
        detection = Detection(
            panel_id=data.panel_id,
            defect_type=data.defect_type.value,
            defect_subtype=data.defect_subtype.value if data.defect_subtype else None,
            confidence=data.confidence,
            bbox_x=data.bbox_x,
            bbox_y=data.bbox_y,
            bbox_width=data.bbox_width,
            bbox_height=data.bbox_height,
            snapshot_url=data.snapshot_url,
            frame_number=data.frame_number,
            area_percentage=data.area_percentage,
        )
        self.db.add(detection)
        await self.db.commit()
        await self.db.refresh(detection)
        logger.info(f"Detection created: id={detection.id}, type={detection.defect_type}")
        return detection

    async def get_detections(
        self,
        user_id: int,
        filter_params: Optional[DetectionFilter] = None,
        offset: int = 0,
        limit: int = 20,
    ) -> Tuple[list[Detection], int]:
        """
        탐지 이력 조회 (필터링, 페이지네이션)

        Args:
            user_id: 사용자 ID (권한 확인용)
            filter_params: 필터 파라미터
            offset: 오프셋
            limit: 제한

        Returns:
            Tuple[list[Detection], int]: (탐지 목록, 전체 개수)
        """
        # 기본 쿼리 - 사용자가 소유한 패널의 탐지만 조회
        base_query = (
            select(Detection)
            .join(Panel)
            .where(Panel.user_id == user_id)
            .options(selectinload(Detection.panel))
        )

        count_query = (
            select(func.count(Detection.id))
            .select_from(Detection)
            .join(Panel)
            .where(Panel.user_id == user_id)
        )

        # 필터 적용
        if filter_params:
            conditions = []

            if filter_params.panel_id is not None:
                conditions.append(Detection.panel_id == filter_params.panel_id)

            if filter_params.defect_type is not None:
                conditions.append(Detection.defect_type == filter_params.defect_type.value)

            if filter_params.defect_subtype is not None:
                conditions.append(Detection.defect_subtype == filter_params.defect_subtype.value)

            if filter_params.min_confidence is not None:
                conditions.append(Detection.confidence >= filter_params.min_confidence)

            if filter_params.max_confidence is not None:
                conditions.append(Detection.confidence <= filter_params.max_confidence)

            if filter_params.start_date is not None:
                start_datetime = datetime.combine(filter_params.start_date, datetime.min.time())
                conditions.append(Detection.detected_at >= start_datetime)

            if filter_params.end_date is not None:
                # end_date의 마지막까지 포함하기 위해 다음 날로 설정
                end_datetime = datetime.combine(
                    filter_params.end_date + timedelta(days=1), 
                    datetime.min.time()
                )
                conditions.append(Detection.detected_at < end_datetime)

            if conditions:
                base_query = base_query.where(and_(*conditions))
                count_query = count_query.where(and_(*conditions))

        # 정렬 (최신순) 및 페이지네이션
        base_query = base_query.order_by(Detection.detected_at.desc()).offset(offset).limit(limit)

        # 실행
        result = await self.db.execute(base_query)
        detections = list(result.scalars().all())

        count_result = await self.db.execute(count_query)
        total_count = count_result.scalar() or 0

        return detections, total_count

    async def get_detection(
        self,
        detection_id: int,
        user_id: int,
    ) -> Optional[Detection]:
        """
        탐지 상세 조회

        Args:
            detection_id: 탐지 ID
            user_id: 사용자 ID (권한 확인용)

        Returns:
            Detection or None
        """
        result = await self.db.execute(
            select(Detection)
            .join(Panel)
            .where(Detection.id == detection_id)
            .where(Panel.user_id == user_id)
            .options(selectinload(Detection.panel))
        )
        return result.scalar_one_or_none()

    async def get_detection_stats(
        self,
        user_id: int,
        panel_id: Optional[int] = None,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
    ) -> DetectionStats:
        """
        탐지 통계 조회

        Args:
            user_id: 사용자 ID
            panel_id: 패널 ID (선택)
            start_date: 시작 날짜 (선택)
            end_date: 종료 날짜 (선택)

        Returns:
            DetectionStats
        """
        # 기본 조건
        conditions = [Panel.user_id == user_id]

        if panel_id is not None:
            conditions.append(Detection.panel_id == panel_id)

        if start_date is not None:
            start_datetime = datetime.combine(start_date, datetime.min.time())
            conditions.append(Detection.detected_at >= start_datetime)

        if end_date is not None:
            end_datetime = datetime.combine(end_date + timedelta(days=1), datetime.min.time())
            conditions.append(Detection.detected_at < end_datetime)

        # 전체 건수
        total_result = await self.db.execute(
            select(func.count(Detection.id))
            .select_from(Detection)
            .join(Panel)
            .where(and_(*conditions))
        )
        total_count = total_result.scalar() or 0

        # 결함 유형별 건수
        defect_result = await self.db.execute(
            select(func.count(Detection.id))
            .select_from(Detection)
            .join(Panel)
            .where(and_(*conditions, Detection.defect_type == "defect"))
        )
        defect_count = defect_result.scalar() or 0

        soiling_result = await self.db.execute(
            select(func.count(Detection.id))
            .select_from(Detection)
            .join(Panel)
            .where(and_(*conditions, Detection.defect_type == "soiling"))
        )
        soiling_count = soiling_result.scalar() or 0

        normal_result = await self.db.execute(
            select(func.count(Detection.id))
            .select_from(Detection)
            .join(Panel)
            .where(and_(*conditions, Detection.defect_type == "normal"))
        )
        normal_count = normal_result.scalar() or 0

        # 평균 신뢰도
        avg_result = await self.db.execute(
            select(func.avg(Detection.confidence))
            .select_from(Detection)
            .join(Panel)
            .where(and_(*conditions))
        )
        avg_confidence = avg_result.scalar()

        return DetectionStats(
            total_count=total_count,
            defect_count=defect_count,
            soiling_count=soiling_count,
            normal_count=normal_count,
            avg_confidence=round(avg_confidence, 4) if avg_confidence else None,
        )
