"""
Solar Eye Backend - Weather API Router

날씨 관련 API 엔드포인트
"""

import logging
from datetime import datetime
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.models.panel import Panel
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.weather import (
    CurrentWeatherResponse,
    ForecastItem,
    ForecastResponse,
    InsightLevel,
    InsightType,
    WeatherInsight,
    WeatherInsightsResponse,
    WeatherStatus,
    WeatherStatusResponse,
)
from app.services.weather_service import WeatherService, convert_lat_lon_to_grid

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/weather", tags=["Weather"])


async def _get_panel_grid(
    db: AsyncSession,
    user_id: int,
    panel_id: Optional[int] = None,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
) -> tuple[int, int, Optional[int], Optional[str]]:
    """
    패널 또는 좌표에서 격자 좌표 조회
    
    Returns:
        tuple[int, int, Optional[int], Optional[str]]: (grid_nx, grid_ny, panel_id, location)
    """
    if panel_id:
        # 패널에서 격자 좌표 조회
        result = await db.execute(
            select(Panel)
            .where(Panel.id == panel_id)
            .where(Panel.user_id == user_id)
        )
        panel = result.scalar_one_or_none()
        
        if not panel:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="패널을 찾을 수 없거나 접근 권한이 없습니다.",
            )
        
        # 패널에 격자 좌표가 저장되어 있으면 사용
        if panel.grid_nx and panel.grid_ny:
            return panel.grid_nx, panel.grid_ny, panel.id, panel.location
        
        # 위경도로부터 변환
        if panel.latitude and panel.longitude:
            nx, ny = convert_lat_lon_to_grid(panel.latitude, panel.longitude)
            return nx, ny, panel.id, panel.location
        
        # 기본 좌표 (서울)
        return 60, 127, panel.id, panel.location
    
    elif latitude is not None and longitude is not None:
        # 좌표에서 직접 변환
        nx, ny = convert_lat_lon_to_grid(latitude, longitude)
        return nx, ny, None, None
    
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="panelId 또는 latitude/longitude를 제공해야 합니다.",
        )


@router.get(
    "/current",
    response_model=SuccessResponse[CurrentWeatherResponse],
    summary="현재 날씨 조회",
    description="특정 패널 위치 또는 좌표의 현재 날씨를 조회합니다.",
)
async def get_current_weather(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID"),
    ] = None,
    latitude: Annotated[
        Optional[float],
        Query(alias="lat", ge=-90, le=90, description="위도"),
    ] = None,
    longitude: Annotated[
        Optional[float],
        Query(alias="lng", ge=-180, le=180, description="경도"),
    ] = None,
):
    """
    현재 날씨 조회
    
    - panelId를 지정하면 해당 패널 위치의 날씨 조회
    - latitude/longitude를 지정하면 해당 좌표의 날씨 조회
    - 결과는 1시간 동안 캐싱됩니다.
    
    **포함 정보:**
    - 기온, 습도, 강수량, 풍속
    - 강수 여부 (비, 눈 등)
    - 날씨 상태 (맑음, 흐림, 비 등)
    """
    grid_nx, grid_ny, p_id, location = await _get_panel_grid(
        db, current_user.id, panel_id, latitude, longitude
    )
    
    weather_service = WeatherService()
    weather_data = await weather_service.get_ultra_srt_ncst(
        grid_nx=grid_nx,
        grid_ny=grid_ny,
        panel_id=p_id,
    )
    
    if not weather_data:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="날씨 정보를 가져올 수 없습니다.",
        )
    
    # 응답 변환
    response = CurrentWeatherResponse(
        panel_id=p_id,
        location=location,
        grid_nx=weather_data["grid_nx"],
        grid_ny=weather_data["grid_ny"],
        temperature=weather_data["temperature"],
        humidity=weather_data["humidity"],
        precipitation=weather_data["precipitation"],
        precipitation_type=weather_data["precipitation_type"],
        wind_speed=weather_data["wind_speed"],
        wind_direction=weather_data.get("wind_direction"),
        weather_status=WeatherStatus(weather_data["weather_status"]),
        is_raining=weather_data["is_raining"],
        observed_at=datetime.fromisoformat(weather_data["observed_at"]),
        is_mock=weather_data.get("is_mock", False),
    )
    
    return SuccessResponse(
        message="현재 날씨 조회 성공",
        data=response,
    )


@router.get(
    "/forecast",
    response_model=SuccessResponse[ForecastResponse],
    summary="단기 예보 조회",
    description="특정 패널 위치 또는 좌표의 단기 예보를 조회합니다.",
)
async def get_forecast(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID"),
    ] = None,
    latitude: Annotated[
        Optional[float],
        Query(alias="lat", ge=-90, le=90, description="위도"),
    ] = None,
    longitude: Annotated[
        Optional[float],
        Query(alias="lng", ge=-180, le=180, description="경도"),
    ] = None,
):
    """
    단기 예보 조회
    
    - 24시간 동안의 3시간 단위 예보 제공
    - 기온, 습도, 강수확률, 날씨 상태 포함
    - 결과는 1시간 동안 캐싱됩니다.
    """
    grid_nx, grid_ny, p_id, location = await _get_panel_grid(
        db, current_user.id, panel_id, latitude, longitude
    )
    
    weather_service = WeatherService()
    forecast_data = await weather_service.get_vilage_fcst(
        grid_nx=grid_nx,
        grid_ny=grid_ny,
        panel_id=p_id,
    )
    
    if not forecast_data:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="예보 정보를 가져올 수 없습니다.",
        )
    
    # 예보 항목 변환
    forecasts = [
        ForecastItem(
            forecast_time=datetime.fromisoformat(fc["forecast_time"]),
            temperature=fc.get("temperature"),
            humidity=fc.get("humidity"),
            precipitation_probability=fc.get("precipitation_probability", 0),
            precipitation=fc.get("precipitation"),
            weather_status=WeatherStatus(fc.get("weather_status", "unknown")),
        )
        for fc in forecast_data["forecasts"]
    ]
    
    response = ForecastResponse(
        panel_id=p_id,
        grid_nx=forecast_data["grid_nx"],
        grid_ny=forecast_data["grid_ny"],
        base_date=forecast_data["base_date"],
        base_time=forecast_data["base_time"],
        forecasts=forecasts,
        is_mock=forecast_data.get("is_mock", False),
    )
    
    return SuccessResponse(
        message="단기 예보 조회 성공",
        data=response,
    )


@router.get(
    "/status",
    response_model=SuccessResponse[WeatherStatusResponse],
    summary="우천 여부 확인",
    description="현재 우천 여부와 곧 비가 올 예정인지 확인합니다.",
)
async def get_weather_status(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID"),
    ] = None,
    latitude: Annotated[
        Optional[float],
        Query(alias="lat", ge=-90, le=90, description="위도"),
    ] = None,
    longitude: Annotated[
        Optional[float],
        Query(alias="lng", ge=-180, le=180, description="경도"),
    ] = None,
):
    """
    우천 여부 확인
    
    - 현재 비가 오고 있는지 확인
    - 3시간 이내 비 예보 확인
    - 오염 탐지 알림 스킵 여부 판단에 활용
    
    **활용:**
    - 비가 오면 오염 탐지 알림을 일시 중지
    - 비가 그치면 자연 세척 효과 기대
    """
    grid_nx, grid_ny, p_id, location = await _get_panel_grid(
        db, current_user.id, panel_id, latitude, longitude
    )
    
    weather_service = WeatherService()
    status_data = await weather_service.check_rain_status(
        grid_nx=grid_nx,
        grid_ny=grid_ny,
        panel_id=p_id,
    )
    
    response = WeatherStatusResponse(
        panel_id=p_id,
        is_raining=status_data["is_raining"],
        will_rain_soon=status_data["will_rain_soon"],
        rain_probability=status_data["rain_probability"],
        message=status_data["message"],
        should_skip_alert=status_data["should_skip_alert"],
    )
    
    return SuccessResponse(
        message="우천 여부 확인 성공",
        data=response,
    )


@router.get(
    "/insights",
    response_model=SuccessResponse[WeatherInsightsResponse],
    summary="스마트 관리 인사이트 조회",
    description="날씨 분석을 통한 행동 가능한 관리 인사이트를 제공합니다.",
)
async def get_weather_insights(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID"),
    ] = None,
    latitude: Annotated[
        Optional[float],
        Query(alias="lat", ge=-90, le=90, description="위도"),
    ] = None,
    longitude: Annotated[
        Optional[float],
        Query(alias="lng", ge=-180, le=180, description="경도"),
    ] = None,
):
    """
    스마트 관리 인사이트 조회
    
    현재 날씨와 예보를 분석하여 태양광 패널 관리에 필요한
    행동 가능한 인사이트(Actionable Insight)를 제공합니다.
    
    **제공하는 인사이트:**
    - 🧹 **자연 세척 추천**: 비가 예보된 경우 청소 보류 권장
    - ❄️ **제설 작업 알림**: 눈 예보 시 제설 일정 안내
    - ⚡ **발전 효율 저하 경고**: 장시간 흐림/우천 예상 시 알림
    - 🌡️ **기온 관련 알림**: 고온/저온 시 효율 저하 및 점검 안내
    - 💨 **강풍 주의보**: 강풍 시 패널 고정 상태 점검 권고
    
    **인사이트 레벨:**
    - `info`: 참고 정보 (일반적인 상황)
    - `warning`: 주의 필요 (예방적 조치 권장)
    - `action_required`: 조치 필요 (즉시 대응 권장)
    """
    grid_nx, grid_ny, p_id, location = await _get_panel_grid(
        db, current_user.id, panel_id, latitude, longitude
    )
    
    weather_service = WeatherService()
    insights_data = await weather_service.analyze_weather_insights(
        grid_nx=grid_nx,
        grid_ny=grid_ny,
        panel_id=p_id,
    )
    
    # 인사이트 변환
    insights = [
        WeatherInsight(
            type=InsightType(insight["type"]),
            level=InsightLevel(insight["level"]),
            message=insight["message"],
            action_item=insight.get("action_item"),
            icon=insight.get("icon"),
        )
        for insight in insights_data.get("insights", [])
    ]
    
    # 현재 날씨 상태 변환
    current_status = insights_data.get("current_weather_status")
    weather_status = None
    if current_status:
        try:
            weather_status = WeatherStatus(current_status)
        except ValueError:
            weather_status = WeatherStatus.UNKNOWN
    
    response = WeatherInsightsResponse(
        panel_id=p_id,
        location=location,
        current_temperature=insights_data.get("current_temperature"),
        current_weather_status=weather_status,
        is_raining=insights_data.get("is_raining", False),
        is_mock=insights_data.get("is_mock", False),
        insights=insights,
        forecast_summary=insights_data.get("forecast_summary"),
        analyzed_at=datetime.fromisoformat(insights_data["analyzed_at"]),
    )
    
    return SuccessResponse(
        message="스마트 관리 인사이트 조회 성공",
        data=response,
    )
