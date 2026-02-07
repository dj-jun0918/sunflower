"""
Solar Eye Backend - Report Service

리포트 관련 비즈니스 로직
"""

import logging
from datetime import date, datetime, timedelta
from typing import Optional, Tuple

from sqlalchemy import and_, func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.daily_report import DailyReport
from app.models.detection import Detection
from app.models.panel import Panel

logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# 경제성 분석 상수
# ─────────────────────────────────────────────────────────────────────────────

# 전력 판매 단가 (원/kWh) - 2024년 기준 SMP 평균
ELECTRICITY_PRICE_KRW = 120.0

# 패널 용량 기준 (kW) - 기본값
DEFAULT_PANEL_CAPACITY_KW = 5.0

# 일일 평균 발전 시간 (시간)
DAILY_GENERATION_HOURS = 3.5

# 오염 면적 대비 효율 손실 비율 (%)
# 오염 면적 1%당 약 0.5~1% 효율 손실
SOILING_EFFICIENCY_LOSS_RATIO = 0.7

# 청소 비용 (원/패널) - 평균 기준
CLEANING_COST_PER_PANEL = 30000

# 청소 권고 기준 오염 면적 비율 (%)
CLEANING_RECOMMENDED_THRESHOLD = 15.0

# 청소 권고 기준 일일 손실 금액 (원)
CLEANING_RECOMMENDED_LOSS_THRESHOLD = 3000


class ReportService:
    """리포트 서비스 클래스"""

    def __init__(self, db: AsyncSession):
        self.db = db

    # ─────────────────────────────────────────────────────────────────────────
    # 일간 리포트
    # ─────────────────────────────────────────────────────────────────────────

    async def get_daily_report(
        self,
        user_id: int,
        panel_id: int,
        report_date: date,
    ) -> Optional[DailyReport]:
        """
        일간 리포트 조회

        Args:
            user_id: 사용자 ID (권한 확인)
            panel_id: 패널 ID
            report_date: 리포트 날짜

        Returns:
            DailyReport 또는 None
        """
        result = await self.db.execute(
            select(DailyReport)
            .join(Panel)
            .where(DailyReport.panel_id == panel_id)
            .where(DailyReport.report_date == report_date)
            .where(Panel.user_id == user_id)
            .options(selectinload(DailyReport.panel))
        )
        return result.scalar_one_or_none()

    async def get_or_create_daily_report(
        self,
        user_id: int,
        panel_id: int,
        report_date: date,
    ) -> Optional[DailyReport]:
        """
        일간 리포트 조회 또는 생성

        Args:
            user_id: 사용자 ID
            panel_id: 패널 ID
            report_date: 리포트 날짜

        Returns:
            DailyReport 또는 None (패널이 없는 경우)
        """
        # 기존 리포트 확인
        existing = await self.get_daily_report(user_id, panel_id, report_date)
        if existing:
            return existing

        # 패널 권한 확인
        panel_result = await self.db.execute(
            select(Panel)
            .where(Panel.id == panel_id)
            .where(Panel.user_id == user_id)
        )
        panel = panel_result.scalar_one_or_none()
        if not panel:
            return None

        # 해당 날짜의 탐지 결과 집계
        stats = await self._aggregate_daily_stats(panel_id, report_date)

        # 경제성 분석 계산
        economic = self._calculate_economic_analysis(
            soiling_area_percent=stats["avg_soiling_area"] or 0,
            capacity_kw=DEFAULT_PANEL_CAPACITY_KW,
        )

        # 리포트 생성
        report = DailyReport(
            panel_id=panel_id,
            report_date=report_date,
            total_detections=stats["total_detections"],
            total_defects=stats["total_defects"],
            total_soiling=stats["total_soiling"],
            avg_soiling_area=stats["avg_soiling_area"],
            max_soiling_area=stats["max_soiling_area"],
            estimated_loss_kwh=economic["daily_loss_kwh"],
            estimated_loss_krw=economic["daily_loss_krw"],
            cleaning_recommended=economic["cleaning_recommended"],
        )

        self.db.add(report)
        await self.db.commit()
        await self.db.refresh(report)

        # 패널 정보 로드
        await self.db.refresh(report, ["panel"])

        logger.info(f"Daily report created: panel_id={panel_id}, date={report_date}")
        return report

    async def _aggregate_daily_stats(
        self,
        panel_id: int,
        report_date: date,
    ) -> dict:
        """탐지 결과 일일 집계"""
        start_dt = datetime.combine(report_date, datetime.min.time())
        end_dt = datetime.combine(report_date + timedelta(days=1), datetime.min.time())

        # 전체 탐지 건수
        total_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id == panel_id)
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
        )
        total_count = total_result.scalar() or 0

        # 결함 건수
        defect_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id == panel_id)
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "defect")
        )
        defect_count = defect_result.scalar() or 0

        # 오염 건수
        soiling_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id == panel_id)
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "soiling")
        )
        soiling_count = soiling_result.scalar() or 0

        # 오염 면적 통계
        area_result = await self.db.execute(
            select(
                func.avg(Detection.area_percentage),
                func.max(Detection.area_percentage),
            )
            .where(Detection.panel_id == panel_id)
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "soiling")
        )
        area_stats = area_result.one()
        avg_area = area_stats[0]
        max_area = area_stats[1]

        return {
            "total_detections": total_count,
            "total_defects": defect_count,
            "total_soiling": soiling_count,
            "avg_soiling_area": round(avg_area, 2) if avg_area else None,
            "max_soiling_area": round(max_area, 2) if max_area else None,
        }

    def _calculate_economic_analysis(
        self,
        soiling_area_percent: float,
        capacity_kw: float = DEFAULT_PANEL_CAPACITY_KW,
    ) -> dict:
        """경제성 분석 계산"""
        # 효율 손실 계산 (오염 면적 비율 * 손실 비율)
        efficiency_loss_percent = soiling_area_percent * SOILING_EFFICIENCY_LOSS_RATIO

        # 일일 발전 손실량 (kWh)
        daily_generation = capacity_kw * DAILY_GENERATION_HOURS
        daily_loss_kwh = daily_generation * (efficiency_loss_percent / 100)

        # 일일 손실 금액 (원)
        daily_loss_krw = daily_loss_kwh * ELECTRICITY_PRICE_KRW

        # 청소 권고 여부
        cleaning_recommended = (
            soiling_area_percent >= CLEANING_RECOMMENDED_THRESHOLD
            or daily_loss_krw >= CLEANING_RECOMMENDED_LOSS_THRESHOLD
        )

        return {
            "efficiency_loss_percent": round(efficiency_loss_percent, 2),
            "daily_loss_kwh": round(daily_loss_kwh, 3),
            "daily_loss_krw": round(daily_loss_krw, 0),
            "cleaning_recommended": cleaning_recommended,
        }

    # ─────────────────────────────────────────────────────────────────────────
    # 주간 리포트
    # ─────────────────────────────────────────────────────────────────────────

    async def get_weekly_report(
        self,
        user_id: int,
        panel_id: int,
        end_date: Optional[date] = None,
    ) -> Optional[dict]:
        """
        주간 리포트 조회

        Args:
            user_id: 사용자 ID
            panel_id: 패널 ID
            end_date: 종료 날짜 (기본값: 오늘)

        Returns:
            주간 리포트 데이터 딕셔너리 또는 None
        """
        if end_date is None:
            end_date = date.today()

        start_date = end_date - timedelta(days=6)

        # 패널 권한 확인
        panel_result = await self.db.execute(
            select(Panel)
            .where(Panel.id == panel_id)
            .where(Panel.user_id == user_id)
        )
        panel = panel_result.scalar_one_or_none()
        if not panel:
            return None

        # 일별 탐지 통계 조회
        start_dt = datetime.combine(start_date, datetime.min.time())
        end_dt = datetime.combine(end_date + timedelta(days=1), datetime.min.time())

        # 일별 트렌드 데이터
        daily_trends = []
        total_detections = 0
        total_defects = 0
        total_soiling = 0
        all_soiling_areas = []

        for i in range(7):
            current_date = start_date + timedelta(days=i)
            stats = await self._aggregate_daily_stats(panel_id, current_date)

            daily_trends.append({
                "date": current_date,
                "defect_count": stats["total_defects"],
                "soiling_count": stats["total_soiling"],
            })

            total_detections += stats["total_detections"]
            total_defects += stats["total_defects"]
            total_soiling += stats["total_soiling"]

            if stats["avg_soiling_area"]:
                all_soiling_areas.append(stats["avg_soiling_area"])

        # 주간 평균 오염 면적
        avg_soiling_area = (
            sum(all_soiling_areas) / len(all_soiling_areas)
            if all_soiling_areas
            else 0
        )

        # 주간 경제성 분석
        economic = self._calculate_economic_analysis(
            soiling_area_percent=avg_soiling_area,
            capacity_kw=DEFAULT_PANEL_CAPACITY_KW,
        )

        # 주간 손실 계산 (일일 * 7)
        weekly_loss_kwh = economic["daily_loss_kwh"] * 7
        weekly_loss_krw = economic["daily_loss_krw"] * 7

        return {
            "panel_id": panel_id,
            "panel_name": panel.name,
            "start_date": start_date,
            "end_date": end_date,
            "total_detections": total_detections,
            "total_defects": total_defects,
            "total_soiling": total_soiling,
            "daily_trends": daily_trends,
            "total_estimated_loss_kwh": round(weekly_loss_kwh, 3),
            "total_estimated_loss_krw": round(weekly_loss_krw, 0),
            "cleaning_recommended": economic["cleaning_recommended"],
        }

    # ─────────────────────────────────────────────────────────────────────────
    # 경제성 분석
    # ─────────────────────────────────────────────────────────────────────────

    async def get_economic_report(
        self,
        user_id: int,
        panel_id: int,
        analysis_date: Optional[date] = None,
    ) -> Optional[dict]:
        """
        경제성 분석 리포트

        Args:
            user_id: 사용자 ID
            panel_id: 패널 ID
            analysis_date: 분석 기준 날짜 (기본값: 오늘)

        Returns:
            경제성 분석 데이터 딕셔너리 또는 None
        """
        if analysis_date is None:
            analysis_date = date.today()

        # 패널 권한 확인
        panel_result = await self.db.execute(
            select(Panel)
            .where(Panel.id == panel_id)
            .where(Panel.user_id == user_id)
        )
        panel = panel_result.scalar_one_or_none()
        if not panel:
            return None

        # 최근 7일 오염 데이터로 평균 오염 면적 계산
        start_date = analysis_date - timedelta(days=6)
        start_dt = datetime.combine(start_date, datetime.min.time())
        end_dt = datetime.combine(analysis_date + timedelta(days=1), datetime.min.time())

        # 최근 오염 탐지 평균 면적
        area_result = await self.db.execute(
            select(func.avg(Detection.area_percentage))
            .where(Detection.panel_id == panel_id)
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "soiling")
        )
        avg_soiling_area = area_result.scalar() or 0

        # 경제성 분석 계산
        capacity_kw = DEFAULT_PANEL_CAPACITY_KW
        efficiency_loss_percent = avg_soiling_area * SOILING_EFFICIENCY_LOSS_RATIO

        # 일일 손실
        daily_generation = capacity_kw * DAILY_GENERATION_HOURS
        daily_loss_kwh = daily_generation * (efficiency_loss_percent / 100)
        daily_loss_krw = daily_loss_kwh * ELECTRICITY_PRICE_KRW

        # 월간 손실 (30일 기준)
        monthly_loss_kwh = daily_loss_kwh * 30
        monthly_loss_krw = daily_loss_krw * 30

        # 청소 비용
        cleaning_cost = CLEANING_COST_PER_PANEL

        # 청소 권고 여부 및 이유
        cleaning_recommended = False
        recommendation_reason = ""
        break_even_days = None

        if daily_loss_krw > 0:
            break_even_days = int(cleaning_cost / daily_loss_krw)

            if avg_soiling_area >= CLEANING_RECOMMENDED_THRESHOLD:
                cleaning_recommended = True
                recommendation_reason = f"오염 면적이 {avg_soiling_area:.1f}%로 권고 기준({CLEANING_RECOMMENDED_THRESHOLD}%)을 초과했습니다."
            elif daily_loss_krw >= CLEANING_RECOMMENDED_LOSS_THRESHOLD:
                cleaning_recommended = True
                recommendation_reason = f"일일 손실 금액이 {daily_loss_krw:,.0f}원으로 청소 비용 대비 효과적입니다."
            elif break_even_days <= 30:
                cleaning_recommended = True
                recommendation_reason = f"청소 후 {break_even_days}일 이내에 비용을 회수할 수 있습니다."
            else:
                recommendation_reason = f"현재 오염 수준({avg_soiling_area:.1f}%)은 경미합니다. 청소는 선택적입니다."
        else:
            recommendation_reason = "최근 오염 탐지 데이터가 없습니다."

        # 요약 메시지
        if cleaning_recommended:
            summary_message = (
                f"🔔 청소를 권장합니다. "
                f"현재 추정 월간 손실은 {monthly_loss_krw:,.0f}원이며, "
                f"청소 비용 {cleaning_cost:,.0f}원 대비 효과적입니다."
            )
        else:
            summary_message = (
                f"✅ 현재 패널 상태는 양호합니다. "
                f"월간 추정 손실 {monthly_loss_krw:,.0f}원은 청소 비용 대비 적은 편입니다."
            )

        return {
            "panel_id": panel_id,
            "panel_name": panel.name,
            "analysis_date": analysis_date,
            "capacity_kw": capacity_kw,
            "panel_count": 1,
            "soiling_area_percent": round(avg_soiling_area, 2),
            "efficiency_loss_percent": round(efficiency_loss_percent, 2),
            "daily_loss_kwh": round(daily_loss_kwh, 3),
            "daily_loss_krw": round(daily_loss_krw, 0),
            "monthly_loss_kwh": round(monthly_loss_kwh, 3),
            "monthly_loss_krw": round(monthly_loss_krw, 0),
            "estimated_cleaning_cost": cleaning_cost,
            "cleaning_recommended": cleaning_recommended,
            "recommendation_reason": recommendation_reason,
            "break_even_days": break_even_days,
            "summary_message": summary_message,
        }

    # ─────────────────────────────────────────────────────────────────────────
    # 리포트 목록 조회
    # ─────────────────────────────────────────────────────────────────────────

    async def get_daily_reports(
        self,
        user_id: int,
        panel_id: Optional[int] = None,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        offset: int = 0,
        limit: int = 20,
    ) -> Tuple[list[DailyReport], int]:
        """
        일간 리포트 목록 조회

        Args:
            user_id: 사용자 ID
            panel_id: 패널 ID (선택)
            start_date: 시작 날짜 (선택)
            end_date: 종료 날짜 (선택)
            offset: 오프셋
            limit: 제한

        Returns:
            Tuple[list[DailyReport], int]: (리포트 목록, 전체 개수)
        """
        base_query = (
            select(DailyReport)
            .join(Panel)
            .where(Panel.user_id == user_id)
            .options(selectinload(DailyReport.panel))
        )

        count_query = (
            select(func.count(DailyReport.id))
            .select_from(DailyReport)
            .join(Panel)
            .where(Panel.user_id == user_id)
        )

        # 필터 적용
        conditions = []

        if panel_id is not None:
            conditions.append(DailyReport.panel_id == panel_id)

        if start_date is not None:
            conditions.append(DailyReport.report_date >= start_date)

        if end_date is not None:
            conditions.append(DailyReport.report_date <= end_date)

        if conditions:
            base_query = base_query.where(and_(*conditions))
            count_query = count_query.where(and_(*conditions))

        # 정렬 및 페이지네이션
        base_query = (
            base_query
            .order_by(DailyReport.report_date.desc())
            .offset(offset)
            .limit(limit)
        )

        # 실행
        result = await self.db.execute(base_query)
        reports = list(result.scalars().all())

        count_result = await self.db.execute(count_query)
        total_count = count_result.scalar() or 0

        return reports, total_count

    # ─────────────────────────────────────────────────────────────────────────
    # AI 브리핑 관련
    # ─────────────────────────────────────────────────────────────────────────

    async def aggregate_all_panels_daily_data(
        self,
        user_id: int,
        target_date: Optional[date] = None,
    ) -> dict:
        """
        전체 패널의 일일 데이터 집계 (AI 브리핑용)

        Args:
            user_id: 사용자 ID
            target_date: 대상 날짜 (기본값: 오늘)

        Returns:
            집계된 데이터 딕셔너리
        """
        if target_date is None:
            target_date = date.today()

        start_dt = datetime.combine(target_date, datetime.min.time())
        end_dt = datetime.combine(target_date + timedelta(days=1), datetime.min.time())

        # 사용자의 모든 패널 조회
        panel_result = await self.db.execute(
            select(Panel).where(Panel.user_id == user_id)
        )
        panels = list(panel_result.scalars().all())
        panel_ids = [p.id for p in panels]

        if not panel_ids:
            return {
                "date": target_date.isoformat(),
                "summary": {"total": 0, "normal": 0, "soiling": 0, "crack": 0},
                "economic_loss": "0원",
            }

        # 전체 탐지 통계
        total_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id.in_(panel_ids))
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
        )
        total_count = total_result.scalar() or 0

        # 결함 건수
        defect_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id.in_(panel_ids))
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "defect")
        )
        crack_count = defect_result.scalar() or 0

        # 오염 건수
        soiling_result = await self.db.execute(
            select(func.count(Detection.id))
            .where(Detection.panel_id.in_(panel_ids))
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "soiling")
        )
        soiling_count = soiling_result.scalar() or 0

        # 정상 건수
        normal_count = total_count - crack_count - soiling_count

        # 평균 오염 면적으로 경제 손실 계산
        area_result = await self.db.execute(
            select(func.avg(Detection.area_percentage))
            .where(Detection.panel_id.in_(panel_ids))
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
            .where(Detection.defect_type == "soiling")
        )
        avg_soiling_area = area_result.scalar() or 0

        # 경제 손실 계산
        economic = self._calculate_economic_analysis(
            soiling_area_percent=avg_soiling_area,
            capacity_kw=DEFAULT_PANEL_CAPACITY_KW * len(panels),
        )
        daily_loss_krw = economic["daily_loss_krw"]

        return {
            "date": target_date.isoformat(),
            "summary": {
                "total": total_count,
                "normal": normal_count,
                "soiling": soiling_count,
                "crack": crack_count,
            },
            "economic_loss": f"약 {daily_loss_krw:,.0f}원",
            "avg_soiling_area": avg_soiling_area,
            "panel_count": len(panels),
        }

    async def extract_anomalies(self, daily_data: dict) -> list[str]:
        """
        특이사항 추출

        Args:
            daily_data: 일일 집계 데이터

        Returns:
            특이사항 문자열 목록
        """
        anomalies = []
        summary = daily_data.get("summary", {})

        crack_count = summary.get("crack", 0)
        soiling_count = summary.get("soiling", 0)

        if crack_count > 0:
            anomalies.append(f"새로운 패널 파손 의심 {crack_count}건 발견됨")

        if soiling_count > 10:
            anomalies.append(f"오염 탐지 {soiling_count}건으로 평소보다 증가")
        elif soiling_count > 5:
            anomalies.append(f"오염 탐지 {soiling_count}건 발생")

        avg_area = daily_data.get("avg_soiling_area", 0)
        if avg_area and avg_area > 20:
            anomalies.append(f"평균 오염 면적 {avg_area:.1f}%로 높음")

        return anomalies

    async def generate_ai_briefing(
        self,
        user_id: int,
        target_date: Optional[date] = None,
    ) -> Optional[DailyReport]:
        """
        AI 브리핑 생성 및 저장

        Args:
            user_id: 사용자 ID
            target_date: 대상 날짜

        Returns:
            생성된 DailyReport 또는 None
        """
        from app.services.gemini_service import get_gemini_service
        from app.services.weather_service import WeatherService

        if target_date is None:
            target_date = date.today()

        # 1. 전체 패널 데이터 집계
        daily_data = await self.aggregate_all_panels_daily_data(user_id, target_date)

        if daily_data["summary"]["total"] == 0:
            logger.info(f"No detections for user {user_id} on {target_date}, skipping AI briefing")
            return None

        # 2. 특이사항 추출
        anomalies = await self.extract_anomalies(daily_data)

        # 3. 내일 날씨 조회 (WeatherService 사용)
        weather_forecast = {"condition": "맑음", "precipitation": 0}
        try:
            weather_service = WeatherService()
            # 춘천 좌표 (기본값)
            tomorrow_weather = await weather_service.get_short_term_forecast(
                nx=73, ny=134  # 춘천
            )
            if tomorrow_weather:
                weather_forecast = {
                    "condition": tomorrow_weather.get("sky", "맑음"),
                    "precipitation": tomorrow_weather.get("pop", 0),
                    "temperature": tomorrow_weather.get("tmp"),
                    "is_mock": tomorrow_weather.get("is_mock", False),
                }
        except Exception as e:
            logger.warning(f"Failed to get weather forecast: {e}")

        # 4. Gemini AI 솔루션 생성
        gemini_service = get_gemini_service()
        ai_solution = await gemini_service.generate_daily_briefing(
            date=daily_data["date"],
            summary=daily_data["summary"],
            anomalies=anomalies,
            weather_forecast=weather_forecast,
            economic_loss=daily_data["economic_loss"],
        )

        # 5. 첫 번째 패널에 대한 리포트 생성/업데이트
        panel_result = await self.db.execute(
            select(Panel).where(Panel.user_id == user_id).limit(1)
        )
        panel = panel_result.scalar_one_or_none()
        if not panel:
            logger.warning(f"No panels found for user {user_id}")
            return None

        # 기존 리포트 조회 또는 생성
        report = await self.get_or_create_daily_report(user_id, panel.id, target_date)
        if not report:
            return None

        # AI 솔루션 필드 업데이트
        report.ai_solution_type = ai_solution["solution_type"]
        report.ai_solution_title = ai_solution["title"]
        report.ai_solution_content = ai_solution["content"]
        report.ai_action_items = ai_solution["action_items"]
        report.anomalies = anomalies
        report.weather_forecast = weather_forecast
        report.ai_generated_at = datetime.now()

        await self.db.commit()
        await self.db.refresh(report)

        logger.info(
            f"AI briefing generated for user {user_id}, date {target_date}: "
            f"type={ai_solution['solution_type']}"
        )

        return report

    async def get_today_ai_briefing(self, user_id: int) -> Optional[DailyReport]:
        """
        오늘의 AI 브리핑 조회

        Args:
            user_id: 사용자 ID

        Returns:
            오늘의 DailyReport (AI 브리핑 포함) 또는 None
        """
        today = date.today()

        result = await self.db.execute(
            select(DailyReport)
            .join(Panel)
            .where(Panel.user_id == user_id)
            .where(DailyReport.report_date == today)
            .where(DailyReport.ai_solution_type.isnot(None))
            .options(selectinload(DailyReport.panel))
            .order_by(DailyReport.ai_generated_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

