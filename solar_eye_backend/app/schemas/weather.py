"""
Solar Eye Backend - Weather Schemas

날씨 관련 Pydantic 스키마 정의
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class WeatherStatus(str, Enum):
    """날씨 상태 열거형"""
    CLEAR = "clear"         # 맑음
    CLOUDY = "cloudy"       # 흐림
    RAINY = "rainy"         # 비
    SNOWY = "snowy"         # 눈
    UNKNOWN = "unknown"     # 알 수 없음


class CurrentWeatherResponse(BaseModel):
    """현재 날씨 응답 스키마"""
    
    panel_id: Optional[int] = Field(None, alias="panelId")
    location: Optional[str] = None
    grid_nx: int = Field(..., alias="gridNx")
    grid_ny: int = Field(..., alias="gridNy")
    temperature: float = Field(..., description="기온 (°C)")
    humidity: int = Field(..., ge=0, le=100, description="습도 (%)")
    precipitation: float = Field(default=0, description="강수량 (mm)")
    precipitation_type: str = Field(..., alias="precipitationType")
    wind_speed: float = Field(..., alias="windSpeed", description="풍속 (m/s)")
    wind_direction: Optional[str] = Field(None, alias="windDirection")
    weather_status: WeatherStatus = Field(..., alias="weatherStatus")
    is_raining: bool = Field(..., alias="isRaining")
    observed_at: datetime = Field(..., alias="observedAt")
    is_mock: bool = Field(default=False, alias="isMock", description="Mock 데이터 여부")
    
    model_config = ConfigDict(populate_by_name=True)


class ForecastItem(BaseModel):
    """예보 항목"""
    forecast_time: datetime = Field(..., alias="forecastTime")
    temperature: Optional[float] = None
    humidity: Optional[int] = None
    precipitation_probability: int = Field(default=0, alias="precipitationProbability")
    precipitation: Optional[float] = None
    weather_status: WeatherStatus = Field(..., alias="weatherStatus")
    
    model_config = ConfigDict(populate_by_name=True)


class ForecastResponse(BaseModel):
    """단기 예보 응답"""
    panel_id: Optional[int] = Field(None, alias="panelId")
    grid_nx: int = Field(..., alias="gridNx")
    grid_ny: int = Field(..., alias="gridNy")
    base_date: str = Field(..., alias="baseDate")
    base_time: str = Field(..., alias="baseTime")
    forecasts: list[ForecastItem] = Field(default_factory=list)
    is_mock: bool = Field(default=False, alias="isMock")
    
    model_config = ConfigDict(populate_by_name=True)


class WeatherStatusResponse(BaseModel):
    """우천 여부 확인 응답"""
    panel_id: Optional[int] = Field(None, alias="panelId")
    is_raining: bool = Field(..., alias="isRaining")
    will_rain_soon: bool = Field(default=False, alias="willRainSoon")
    rain_probability: int = Field(default=0, alias="rainProbability")
    message: str = Field(...)
    should_skip_alert: bool = Field(default=False, alias="shouldSkipAlert")
    
    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 스마트 인사이트 관련 스키마
# ─────────────────────────────────────────────────────────────────────────────

class InsightType(str, Enum):
    """인사이트 타입 열거형"""
    CLEANING = "cleaning"          # 청소 관련
    MAINTENANCE = "maintenance"    # 유지보수 관련
    EFFICIENCY = "efficiency"      # 효율 관련
    ALERT = "alert"               # 긴급 알림


class InsightLevel(str, Enum):
    """인사이트 중요도 레벨"""
    INFO = "info"                   # 정보 (참고용)
    WARNING = "warning"             # 주의 (고려 필요)
    ACTION_REQUIRED = "action_required"  # 조치필요 (즉시 대응)


class WeatherInsight(BaseModel):
    """날씨 기반 관리 인사이트"""
    type: InsightType = Field(..., description="인사이트 유형")
    level: InsightLevel = Field(..., description="중요도 레벨")
    message: str = Field(..., description="인사이트 메시지")
    action_item: Optional[str] = Field(None, alias="actionItem", description="구체적 행동 제안")
    icon: Optional[str] = Field(None, description="프론트엔드용 아이콘 힌트")
    
    model_config = ConfigDict(populate_by_name=True)


class WeatherInsightsResponse(BaseModel):
    """스마트 날씨 인사이트 응답"""
    panel_id: Optional[int] = Field(None, alias="panelId")
    location: Optional[str] = None
    
    # 현재 날씨 요약
    current_temperature: Optional[float] = Field(None, alias="currentTemperature")
    current_weather_status: Optional[WeatherStatus] = Field(None, alias="currentWeatherStatus")
    is_raining: bool = Field(default=False, alias="isRaining")
    is_mock: bool = Field(default=False, alias="isMock")
    
    # 인사이트 목록
    insights: list[WeatherInsight] = Field(default_factory=list)
    
    # 3일 예보 요약
    forecast_summary: Optional[str] = Field(None, alias="forecastSummary")
    
    # 조회 시점
    analyzed_at: datetime = Field(..., alias="analyzedAt")
    
    model_config = ConfigDict(populate_by_name=True)
