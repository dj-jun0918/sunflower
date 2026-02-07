"""
Solar Eye Backend - Report Schemas

리포트 관련 Pydantic 스키마 정의
"""

from datetime import date, datetime
from typing import Any, Optional

from pydantic import BaseModel, ConfigDict, Field


class DailyReportResponse(BaseModel):
    """일간 리포트 응답 스키마"""
    
    id: int = Field(..., description="리포트 ID")
    panel_id: int = Field(..., alias="panelId", description="패널 ID")
    panel_name: Optional[str] = Field(None, alias="panelName")
    report_date: date = Field(..., alias="reportDate")
    total_detections: int = Field(..., alias="totalDetections")
    total_defects: int = Field(..., alias="totalDefects")
    total_soiling: int = Field(..., alias="totalSoiling")
    avg_soiling_area: Optional[float] = Field(None, alias="avgSoilingArea")
    max_soiling_area: Optional[float] = Field(None, alias="maxSoilingArea")
    estimated_loss_kwh: Optional[float] = Field(None, alias="estimatedLossKwh")
    estimated_loss_krw: Optional[float] = Field(None, alias="estimatedLossKrw")
    cleaning_recommended: bool = Field(..., alias="cleaningRecommended")
    weather_summary: Optional[str] = Field(None, alias="weatherSummary")
    had_rain: bool = Field(..., alias="hadRain")
    summary: Optional[dict[str, Any]] = None
    created_at: datetime = Field(..., alias="createdAt")

    model_config = ConfigDict(from_attributes=True, populate_by_name=True)


class DailyTrend(BaseModel):
    """일별 트렌드"""
    date: date
    defect_count: int = Field(..., alias="defectCount")
    soiling_count: int = Field(..., alias="soilingCount")
    model_config = ConfigDict(populate_by_name=True)


class WeeklyReportResponse(BaseModel):
    """주간 리포트 응답"""
    panel_id: int = Field(..., alias="panelId")
    panel_name: Optional[str] = Field(None, alias="panelName")
    start_date: date = Field(..., alias="startDate")
    end_date: date = Field(..., alias="endDate")
    total_detections: int = Field(..., alias="totalDetections")
    total_defects: int = Field(..., alias="totalDefects")
    total_soiling: int = Field(..., alias="totalSoiling")
    daily_trends: list[DailyTrend] = Field(default_factory=list, alias="dailyTrends")
    total_estimated_loss_kwh: Optional[float] = Field(None, alias="totalEstimatedLossKwh")
    total_estimated_loss_krw: Optional[float] = Field(None, alias="totalEstimatedLossKrw")
    cleaning_recommended: bool = Field(..., alias="cleaningRecommended")
    model_config = ConfigDict(populate_by_name=True)


class EconomicReportResponse(BaseModel):
    """경제성 분석 리포트"""
    panel_id: int = Field(..., alias="panelId")
    panel_name: Optional[str] = Field(None, alias="panelName")
    analysis_date: date = Field(..., alias="analysisDate")
    capacity_kw: Optional[float] = Field(None, alias="capacityKw")
    panel_count: Optional[int] = Field(None, alias="panelCount")
    soiling_area_percent: float = Field(..., alias="soilingAreaPercent")
    efficiency_loss_percent: float = Field(..., alias="efficiencyLossPercent")
    daily_loss_kwh: float = Field(..., alias="dailyLossKwh")
    daily_loss_krw: float = Field(..., alias="dailyLossKrw")
    monthly_loss_kwh: float = Field(..., alias="monthlyLossKwh")
    monthly_loss_krw: float = Field(..., alias="monthlyLossKrw")
    estimated_cleaning_cost: float = Field(..., alias="estimatedCleaningCost")
    cleaning_recommended: bool = Field(..., alias="cleaningRecommended")
    recommendation_reason: str = Field(..., alias="recommendationReason")
    break_even_days: Optional[int] = Field(None, alias="breakEvenDays")
    summary_message: str = Field(..., alias="summaryMessage")
    model_config = ConfigDict(populate_by_name=True)


class ReportFilter(BaseModel):
    """리포트 필터"""
    panel_id: Optional[int] = Field(None, alias="panelId")
    start_date: Optional[date] = Field(None, alias="startDate")
    end_date: Optional[date] = Field(None, alias="endDate")
    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# AI 브리핑 관련 스키마
# ─────────────────────────────────────────────────────────────────────────────


class AISolutionResponse(BaseModel):
    """AI 솔루션 응답"""
    solution_type: str = Field(..., alias="solutionType", description="솔루션 타입 (good/caution/danger)")
    title: str = Field(..., description="한줄 요약")
    content: str = Field(..., description="상세 설명")
    action_items: list[str] = Field(default_factory=list, alias="actionItems", description="액션 아이템 목록")
    model_config = ConfigDict(populate_by_name=True)


class AIBriefingResponse(BaseModel):
    """AI 일일 브리핑 응답"""
    id: int = Field(..., description="리포트 ID")
    report_date: date = Field(..., alias="reportDate", description="리포트 날짜")
    
    # 탐지 요약
    total_detections: int = Field(..., alias="totalDetections")
    total_defects: int = Field(..., alias="totalDefects")
    total_soiling: int = Field(..., alias="totalSoiling")
    
    # AI 솔루션
    ai_solution: Optional[AISolutionResponse] = Field(None, alias="aiSolution")
    
    # 특이사항
    anomalies: list[str] = Field(default_factory=list, description="특이사항 목록")
    
    # 날씨 정보
    weather_forecast: Optional[dict[str, Any]] = Field(None, alias="weatherForecast")
    
    # 경제 손실
    estimated_loss_krw: Optional[float] = Field(None, alias="estimatedLossKrw")
    cleaning_recommended: bool = Field(..., alias="cleaningRecommended")
    
    # 시간 정보
    ai_generated_at: Optional[datetime] = Field(None, alias="aiGeneratedAt")
    created_at: datetime = Field(..., alias="createdAt")
    
    model_config = ConfigDict(from_attributes=True, populate_by_name=True)

