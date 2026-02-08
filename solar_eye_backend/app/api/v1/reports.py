"""
Solar Eye Backend - Report API Router

리포트 관련 API 엔드포인트
"""

import logging
from datetime import date
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, get_pagination, PaginationParams
from app.models.user import User
from app.schemas.common import PaginatedResponse, PaginationMeta, SuccessResponse
from app.schemas.report import (
    DailyReportResponse,
    DailyTrend,
    EconomicReportResponse,
    WeeklyReportResponse,
)
from app.services.report_service import ReportService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.get(
    "/daily",
    response_model=SuccessResponse[DailyReportResponse],
    summary="일간 리포트 조회",
    description="특정 패널의 일간 리포트를 조회합니다.",
)
async def get_daily_report(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        int,
        Query(alias="panelId", description="패널 ID"),
    ],
    report_date: Annotated[
        Optional[date],
        Query(alias="date", description="리포트 날짜 (YYYY-MM-DD, 기본값: 오늘)"),
    ] = None,
):
    """
    일간 리포트 조회

    - 특정 패널의 해당 날짜 일간 리포트를 조회합니다.
    - 리포트가 없는 경우 자동으로 생성합니다.

    **포함 정보:**
    - 탐지 건수 (결함, 오염)
    - 오염 면적 통계
    - 추정 발전 손실
    - 청소 권고 여부
    """
    if report_date is None:
        report_date = date.today()

    report_service = ReportService(db)
    report = await report_service.get_or_create_daily_report(
        user_id=current_user.id,
        panel_id=panel_id,
        report_date=report_date,
    )

    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없거나 접근 권한이 없습니다.",
        )

    # 응답 변환
    response = DailyReportResponse(
        id=report.id,
        panel_id=report.panel_id,
        panel_name=report.panel.name if report.panel else None,
        report_date=report.report_date,
        total_detections=report.total_detections,
        total_defects=report.total_defects,
        total_soiling=report.total_soiling,
        avg_soiling_area=report.avg_soiling_area,
        max_soiling_area=report.max_soiling_area,
        estimated_loss_kwh=report.estimated_loss_kwh,
        estimated_loss_krw=report.estimated_loss_krw,
        cleaning_recommended=report.cleaning_recommended,
        weather_summary=report.weather_summary,
        had_rain=report.had_rain,
        summary=report.summary,
        created_at=report.created_at,
    )

    return SuccessResponse(
        message="일간 리포트 조회 성공",
        data=response,
    )


@router.get(
    "/daily/list",
    response_model=PaginatedResponse[DailyReportResponse],
    summary="일간 리포트 목록 조회",
    description="일간 리포트 목록을 조회합니다.",
)
async def get_daily_reports(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    pagination: Annotated[PaginationParams, Depends(get_pagination)],
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID 필터"),
    ] = None,
    start_date: Annotated[
        Optional[date],
        Query(alias="startDate", description="시작 날짜"),
    ] = None,
    end_date: Annotated[
        Optional[date],
        Query(alias="endDate", description="종료 날짜"),
    ] = None,
):
    """
    일간 리포트 목록 조회

    - 사용자의 모든 패널에 대한 일간 리포트 목록을 조회합니다.
    - 패널 ID 또는 날짜 범위로 필터링할 수 있습니다.
    """
    report_service = ReportService(db)
    reports, total = await report_service.get_daily_reports(
        user_id=current_user.id,
        panel_id=panel_id,
        start_date=start_date,
        end_date=end_date,
        offset=pagination.offset,
        limit=pagination.limit,
    )

    # 응답 변환
    report_list = [
        DailyReportResponse(
            id=r.id,
            panel_id=r.panel_id,
            panel_name=r.panel.name if r.panel else None,
            report_date=r.report_date,
            total_detections=r.total_detections,
            total_defects=r.total_defects,
            total_soiling=r.total_soiling,
            avg_soiling_area=r.avg_soiling_area,
            max_soiling_area=r.max_soiling_area,
            estimated_loss_kwh=r.estimated_loss_kwh,
            estimated_loss_krw=r.estimated_loss_krw,
            cleaning_recommended=r.cleaning_recommended,
            weather_summary=r.weather_summary,
            had_rain=r.had_rain,
            summary=r.summary,
            created_at=r.created_at,
        )
        for r in reports
    ]

    return PaginatedResponse(
        data=report_list,
        pagination=PaginationMeta.create(
            page=pagination.page,
            page_size=pagination.size,
            total_items=total,
        ),
    )


@router.get(
    "/weekly",
    response_model=SuccessResponse[WeeklyReportResponse],
    summary="주간 리포트 조회",
    description="특정 패널의 주간 리포트를 조회합니다.",
)
async def get_weekly_report(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        int,
        Query(alias="panelId", description="패널 ID"),
    ],
    end_date: Annotated[
        Optional[date],
        Query(alias="endDate", description="종료 날짜 (기본값: 오늘, 이 날짜 포함 최근 7일)"),
    ] = None,
):
    """
    주간 리포트 조회

    - 특정 패널의 최근 7일간 리포트를 조회합니다.
    - 일별 트렌드와 주간 합계를 포함합니다.

    **포함 정보:**
    - 일별 탐지 트렌드
    - 주간 총 탐지 건수
    - 주간 추정 손실
    - 청소 권고 여부
    """
    if end_date is None:
        end_date = date.today()

    report_service = ReportService(db)
    report = await report_service.get_weekly_report(
        user_id=current_user.id,
        panel_id=panel_id,
        end_date=end_date,
    )

    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없거나 접근 권한이 없습니다.",
        )

    # 응답 변환
    daily_trends = [
        DailyTrend(
            date=t["date"],
            defect_count=t["defect_count"],
            soiling_count=t["soiling_count"],
        )
        for t in report["daily_trends"]
    ]

    response = WeeklyReportResponse(
        panel_id=report["panel_id"],
        panel_name=report["panel_name"],
        start_date=report["start_date"],
        end_date=report["end_date"],
        total_detections=report["total_detections"],
        total_defects=report["total_defects"],
        total_soiling=report["total_soiling"],
        daily_trends=daily_trends,
        total_estimated_loss_kwh=report["total_estimated_loss_kwh"],
        total_estimated_loss_krw=report["total_estimated_loss_krw"],
        cleaning_recommended=report["cleaning_recommended"],
    )

    return SuccessResponse(
        message="주간 리포트 조회 성공",
        data=response,
    )


@router.get(
    "/economic",
    response_model=SuccessResponse[EconomicReportResponse],
    summary="경제성 분석",
    description="특정 패널의 경제성 분석 리포트를 조회합니다.",
)
async def get_economic_report(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        int,
        Query(alias="panelId", description="패널 ID"),
    ],
    analysis_date: Annotated[
        Optional[date],
        Query(alias="date", description="분석 기준 날짜 (기본값: 오늘)"),
    ] = None,
):
    """
    경제성 분석 조회

    - 최근 7일 오염 데이터를 기반으로 경제성 분석을 수행합니다.
    - 손실 비용과 청소 비용을 비교하여 권고사항을 제공합니다.

    **분석 항목:**
    - 오염 면적 → 효율 손실 추정
    - 일일/월간 손실 금액
    - 청소 비용 대비 효과
    - 손익 분기점 계산
    - 청소 권고 여부 및 사유
    """
    if analysis_date is None:
        analysis_date = date.today()

    report_service = ReportService(db)
    report = await report_service.get_economic_report(
        user_id=current_user.id,
        panel_id=panel_id,
        analysis_date=analysis_date,
    )

    if not report:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없거나 접근 권한이 없습니다.",
        )

    # 응답 변환
    response = EconomicReportResponse(
        panel_id=report["panel_id"],
        panel_name=report["panel_name"],
        analysis_date=report["analysis_date"],
        capacity_kw=report["capacity_kw"],
        panel_count=report["panel_count"],
        soiling_area_percent=report["soiling_area_percent"],
        efficiency_loss_percent=report["efficiency_loss_percent"],
        daily_loss_kwh=report["daily_loss_kwh"],
        daily_loss_krw=report["daily_loss_krw"],
        monthly_loss_kwh=report["monthly_loss_kwh"],
        monthly_loss_krw=report["monthly_loss_krw"],
        estimated_cleaning_cost=report["estimated_cleaning_cost"],
        cleaning_recommended=report["cleaning_recommended"],
        recommendation_reason=report["recommendation_reason"],
        break_even_days=report["break_even_days"],
        summary_message=report["summary_message"],
    )

    return SuccessResponse(
        message="경제성 분석 조회 성공",
        data=response,
    )


# ─────────────────────────────────────────────────────────────────────────────
# AI 브리핑 관련 엔드포인트
# ─────────────────────────────────────────────────────────────────────────────


@router.get(
    "/ai-briefing/today",
    response_model=SuccessResponse,
    summary="오늘의 AI 브리핑 조회",
    description="오늘의 AI 생성 일일 브리핑을 조회합니다.",
)
async def get_today_ai_briefing(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    오늘의 AI 브리핑 조회

    - 오늘 생성된 AI 일일 브리핑을 반환합니다.
    - 아직 생성되지 않은 경우 null을 반환합니다.

    **포함 정보:**
    - 탐지 요약 (정상/오염/파손)
    - AI 솔루션 (타입, 요약, 상세 설명, 액션 아이템)
    - 특이사항 목록
    - 내일 날씨 예보
    """
    from app.schemas.report import AIBriefingResponse, AISolutionResponse

    report_service = ReportService(db)
    report = await report_service.get_today_ai_briefing(user_id=current_user.id)

    if not report:
        return SuccessResponse(
            message="아직 오늘의 AI 브리핑이 생성되지 않았습니다.",
            data=None,
        )

    # AI 솔루션 변환
    ai_solution = None
    if report.ai_solution_type:
        ai_solution = AISolutionResponse(
            solution_type=report.ai_solution_type,
            title=report.ai_solution_title or "",
            content=report.ai_solution_content or "",
            action_items=report.ai_action_items or [],
        )

    response = AIBriefingResponse(
        id=report.id,
        report_date=report.report_date,
        total_detections=report.total_detections,
        total_defects=report.total_defects,
        total_soiling=report.total_soiling,
        ai_solution=ai_solution,
        anomalies=report.anomalies or [],
        weather_forecast=report.weather_forecast,
        estimated_loss_krw=report.estimated_loss_krw,
        cleaning_recommended=report.cleaning_recommended,
        ai_generated_at=report.ai_generated_at,
        created_at=report.created_at,
    )

    return SuccessResponse(
        message="오늘의 AI 브리핑 조회 성공",
        data=response,
    )


@router.post(
    "/ai-briefing/generate",
    response_model=SuccessResponse,
    summary="AI 브리핑 생성",
    description="즉시 AI 브리핑을 생성합니다. (테스트/수동 생성용)",
)
async def generate_ai_briefing(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    target_date: Annotated[
        Optional[date],
        Query(alias="date", description="대상 날짜 (기본값: 오늘)"),
    ] = None,
):
    """
    AI 브리핑 즉시 생성

    - 수동으로 AI 브리핑을 생성합니다.
    - 주로 테스트 또는 재생성 목적으로 사용합니다.

    **프로세스:**
    1. 오늘의 탐지 데이터 집계
    2. 특이사항 추출
    3. 내일 날씨 조회
    4. Gemini AI 솔루션 생성
    5. 리포트 저장
    """
    from app.schemas.report import AIBriefingResponse, AISolutionResponse

    report_service = ReportService(db)
    
    try:
        report = await report_service.generate_ai_briefing(
            user_id=current_user.id,
            target_date=target_date,
        )
    except Exception as e:
        logger.error(f"AI briefing generation failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI 브리핑 생성에 실패했습니다: {str(e)}",
        )

    if not report:
        return SuccessResponse(
            message="오늘 탐지 데이터가 없어 AI 브리핑을 생성할 수 없습니다.",
            data=None,
        )

    # AI 솔루션 변환
    ai_solution = None
    if report.ai_solution_type:
        ai_solution = AISolutionResponse(
            solution_type=report.ai_solution_type,
            title=report.ai_solution_title or "",
            content=report.ai_solution_content or "",
            action_items=report.ai_action_items or [],
        )

    response = AIBriefingResponse(
        id=report.id,
        report_date=report.report_date,
        total_detections=report.total_detections,
        total_defects=report.total_defects,
        total_soiling=report.total_soiling,
        ai_solution=ai_solution,
        anomalies=report.anomalies or [],
        weather_forecast=report.weather_forecast,
        estimated_loss_krw=report.estimated_loss_krw,
        cleaning_recommended=report.cleaning_recommended,
        ai_generated_at=report.ai_generated_at,
        created_at=report.created_at,
    )

    return SuccessResponse(
        message="AI 브리핑 생성 성공",
        data=response,
    )

