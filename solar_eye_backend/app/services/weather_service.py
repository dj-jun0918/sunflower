"""
Solar Eye Backend - Weather Service

기상청 API 연동 및 날씨 정보 관리
"""

import json
import logging
import math
from datetime import datetime, timedelta
from typing import Optional

import httpx

from app.config import settings
from app.core.redis import CacheKeys, cache_get, cache_set

logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# 기상청 API 코드 정의
# ─────────────────────────────────────────────────────────────────────────────

# 강수형태 코드
PTY_CODE = {
    "0": "없음",
    "1": "비",
    "2": "비/눈",
    "3": "눈",
    "4": "소나기",
    "5": "빗방울",
    "6": "빗방울눈날림",
    "7": "눈날림",
}

# 하늘상태 코드
SKY_CODE = {
    "1": "맑음",
    "3": "구름많음",
    "4": "흐림",
}


# ─────────────────────────────────────────────────────────────────────────────
# 위경도 → 격자 좌표 변환
# ─────────────────────────────────────────────────────────────────────────────

def convert_lat_lon_to_grid(lat: float, lon: float) -> tuple[int, int]:
    """
    위도/경도를 기상청 격자 좌표로 변환
    
    기상청 단기예보 조회서비스에서 사용하는 LCC (Lambert Conformal Conic) 격자 변환
    
    Args:
        lat: 위도 (예: 37.5665)
        lon: 경도 (예: 126.9780)
    
    Returns:
        tuple[int, int]: (격자 X, 격자 Y)
    """
    # 격자 변환 상수 (기상청 기술문서 기준)
    RE = 6371.00877  # 지구 반경 (km)
    GRID = 5.0  # 격자 간격 (km)
    SLAT1 = 30.0  # 투영 위도1 (degree)
    SLAT2 = 60.0  # 투영 위도2 (degree)
    OLON = 126.0  # 기준점 경도 (degree)
    OLAT = 38.0  # 기준점 위도 (degree)
    XO = 43  # 기준점 X 좌표 (GRID)
    YO = 136  # 기준점 Y 좌표 (GRID)

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


def get_base_datetime_for_ultra_srt_ncst() -> tuple[str, str]:
    """
    초단기실황 조회용 기준 시간 계산
    
    초단기실황은 매시 정각에 생성되며, 
    API 제공 시간은 매시 40분 이후
    
    Returns:
        tuple[str, str]: (base_date "YYYYMMDD", base_time "HHMM")
    """
    now = datetime.now()
    
    # 40분 이후면 현재 시간대, 아니면 이전 시간대
    if now.minute >= 40:
        base_time = now.replace(minute=0, second=0, microsecond=0)
    else:
        base_time = now.replace(minute=0, second=0, microsecond=0) - timedelta(hours=1)
    
    base_date = base_time.strftime("%Y%m%d")
    base_time_str = base_time.strftime("%H00")
    
    return base_date, base_time_str


def get_base_datetime_for_vilage_fcst() -> tuple[str, str]:
    """
    단기예보 조회용 기준 시간 계산
    
    단기예보는 0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300에 발표
    각 발표 시간의 10분 이후 API 제공
    
    Returns:
        tuple[str, str]: (base_date "YYYYMMDD", base_time "HHMM")
    """
    now = datetime.now()
    base_times = [2, 5, 8, 11, 14, 17, 20, 23]
    
    current_hour = now.hour
    current_minute = now.minute
    
    # 현재 시간보다 이전의 가장 가까운 발표 시간 찾기
    selected_hour = None
    for bt in reversed(base_times):
        if current_hour > bt or (current_hour == bt and current_minute >= 10):
            selected_hour = bt
            break
    
    if selected_hour is None:
        # 자정~02:10 사이면 전날 23시 사용
        selected_hour = 23
        now = now - timedelta(days=1)
    
    base_date = now.strftime("%Y%m%d")
    base_time_str = f"{selected_hour:02d}00"
    
    return base_date, base_time_str


# ─────────────────────────────────────────────────────────────────────────────
# 날씨 서비스 클래스
# ─────────────────────────────────────────────────────────────────────────────

class WeatherService:
    """기상청 API 연동 서비스"""
    
    def __init__(self):
        self.api_key = settings.weather_api_key
        self.base_url = settings.weather_api_base_url
        self.timeout = 10.0
    
    def _is_available(self) -> bool:
        """API 사용 가능 여부"""
        return self.api_key is not None and len(self.api_key) > 0
    
    async def get_ultra_srt_ncst(
        self,
        grid_nx: int,
        grid_ny: int,
        panel_id: Optional[int] = None,
    ) -> Optional[dict]:
        """
        초단기실황 조회 (getUltraSrtNcst)
        
        현재 기온, 습도, 강수량, 풍속 등 실황 정보
        
        Args:
            grid_nx: 격자 X 좌표
            grid_ny: 격자 Y 좌표
            panel_id: 패널 ID (캐싱용)
        
        Returns:
            dict: 파싱된 날씨 정보 또는 None
        """
        if not self._is_available():
            logger.warning("Weather API key not configured")
            return self._get_mock_current_weather(grid_nx, grid_ny)
        
        # 캐시 확인
        if panel_id:
            cache_key = CacheKeys.weather_current(panel_id)
            cached = await cache_get(cache_key)
            if cached:
                logger.debug(f"Weather cache hit: {cache_key}")
                return json.loads(cached)
        
        base_date, base_time = get_base_datetime_for_ultra_srt_ncst()
        
        params = {
            "serviceKey": self.api_key,
            "numOfRows": 10,
            "pageNo": 1,
            "dataType": "JSON",
            "base_date": base_date,
            "base_time": base_time,
            "nx": grid_nx,
            "ny": grid_ny,
        }
        
        try:
            logger.debug(f"Calling Weather API: {self.base_url}/getUltraSrtNcst with params: {params}")
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(
                    f"{self.base_url}/getUltraSrtNcst",
                    params=params,
                )
                response.raise_for_status()
                data = response.json()
                logger.debug(f"Weather API Response: {data}")
            
            # 응답 파싱
            result = self._parse_ultra_srt_ncst(data, grid_nx, grid_ny)
            
            if result is None:
                logger.warning(f"Failed to parse weather data. Falling back to mock. Data: {data}")
                return self._get_mock_current_weather(grid_nx, grid_ny)

            # 캐시 저장 (Mock 데이터가 아닐 때만 저장)
            if result and not result.get("is_mock") and panel_id:
                await cache_set(
                    cache_key,
                    json.dumps(result, default=str),
                    CacheKeys.WEATHER_TTL,
                )
            elif result.get("is_mock"):
                logger.debug("Skipping cache for mock weather data")
            
            return result
            
        except httpx.TimeoutException:
            logger.error("Weather API timeout")
            return self._get_mock_current_weather(grid_nx, grid_ny)
        except httpx.HTTPStatusError as e:
            logger.error(f"Weather API HTTP error: {e}")
            return self._get_mock_current_weather(grid_nx, grid_ny)
        except Exception as e:
            logger.error(f"Weather API error: {e}, type: {type(e)}")
            return self._get_mock_current_weather(grid_nx, grid_ny)
    
    def _parse_ultra_srt_ncst(
        self,
        data: dict,
        grid_nx: int,
        grid_ny: int,
    ) -> Optional[dict]:
        """초단기실황 API 응답 파싱"""
        try:
            items = data["response"]["body"]["items"]["item"]
            
            weather_data = {
                "grid_nx": grid_nx,
                "grid_ny": grid_ny,
                "temperature": None,
                "humidity": None,
                "precipitation": 0,
                "precipitation_type": "없음",
                "wind_speed": None,
                "wind_direction": None,
                "weather_status": "unknown",
                "is_raining": False,
                "observed_at": datetime.now().isoformat(),
                "is_mock": False,
            }
            
            for item in items:
                category = item.get("category")
                value = item.get("obsrValue")
                
                if category == "T1H":  # 기온
                    val = float(value)
                    weather_data["temperature"] = val if val > -50 else None
                elif category == "RN1":  # 1시간 강수량
                    weather_data["precipitation"] = float(value) if value != "강수없음" else 0
                elif category == "REH":  # 습도
                    val = float(value)
                    weather_data["humidity"] = int(val) if val >= 0 else None
                elif category == "PTY":  # 강수형태
                    weather_data["precipitation_type"] = PTY_CODE.get(value, "없음")
                    weather_data["is_raining"] = value in ["1", "2", "4", "5", "6"]
                elif category == "WSD":  # 풍속
                    val = float(value)
                    weather_data["wind_speed"] = val if val >= 0 else None
                elif category == "VEC":  # 풍향
                    val = float(value)
                    weather_data["wind_direction"] = self._get_wind_direction(val) if val >= 0 else None
            
            # 필수 데이터 확인
            if weather_data["temperature"] is None:
                logger.warning("Missing required temperature data in API response")
                return None

            # 날씨 상태 결정
            if weather_data["is_raining"]:
                weather_data["weather_status"] = "rainy"
            elif weather_data["precipitation_type"] in ["눈", "눈날림", "빗방울눈날림"]:
                weather_data["weather_status"] = "snowy"
            else:
                weather_data["weather_status"] = "clear"
            
            return weather_data
            
        except (KeyError, TypeError, ValueError) as e:
            logger.error(f"Failed to parse weather data: {e}")
            return None
    
    def _get_wind_direction(self, degree: float) -> str:
        """풍향 각도를 방향으로 변환"""
        directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                     "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        idx = int((degree + 11.25) / 22.5) % 16
        return directions[idx]
    
    async def get_vilage_fcst(
        self,
        grid_nx: int,
        grid_ny: int,
        panel_id: Optional[int] = None,
    ) -> Optional[dict]:
        """
        단기예보 조회 (getVilageFcst)
        
        3일간의 예보 정보 (3시간 단위)
        
        Args:
            grid_nx: 격자 X 좌표
            grid_ny: 격자 Y 좌표
            panel_id: 패널 ID (캐싱용)
        
        Returns:
            dict: 파싱된 예보 정보 또는 None
        """
        if not self._is_available():
            logger.warning("Weather API key not configured")
            return self._get_mock_forecast(grid_nx, grid_ny)
        
        # 캐시 확인
        if panel_id:
            cache_key = CacheKeys.weather_forecast(panel_id)
            cached = await cache_get(cache_key)
            if cached:
                logger.debug(f"Forecast cache hit: {cache_key}")
                return json.loads(cached)
        
        base_date, base_time = get_base_datetime_for_vilage_fcst()
        
        params = {
            "serviceKey": self.api_key,
            "numOfRows": 1000,
            "pageNo": 1,
            "dataType": "JSON",
            "base_date": base_date,
            "base_time": base_time,
            "nx": grid_nx,
            "ny": grid_ny,
        }
        
        try:
            logger.debug(f"Calling Forecast API: {self.base_url}/getVilageFcst with params: {params}")
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(
                    f"{self.base_url}/getVilageFcst",
                    params=params,
                )
                response.raise_for_status()
                data = response.json()
                logger.debug(f"Forecast API Response: {data}")
            
            # 응답 파싱
            result = self._parse_vilage_fcst(data, grid_nx, grid_ny, base_date, base_time)
            
            if result is None:
                logger.warning(f"Failed to parse forecast data. Falling back to mock. Data: {data}")
                return self._get_mock_forecast(grid_nx, grid_ny)

            # 캐시 저장
            if result and panel_id:
                await cache_set(
                    cache_key,
                    json.dumps(result, default=str),
                    CacheKeys.WEATHER_TTL,
                )
            
            return result
            
        except httpx.TimeoutException:
            logger.error("Forecast API timeout")
            return self._get_mock_forecast(grid_nx, grid_ny)
        except httpx.HTTPStatusError as e:
            logger.error(f"Forecast API HTTP error: {e}")
            return self._get_mock_forecast(grid_nx, grid_ny)
        except Exception as e:
            logger.error(f"Forecast API error: {e}, type: {type(e)}")
            return self._get_mock_forecast(grid_nx, grid_ny)
    
    def _parse_vilage_fcst(
        self,
        data: dict,
        grid_nx: int,
        grid_ny: int,
        base_date: str,
        base_time: str,
    ) -> Optional[dict]:
        """단기예보 API 응답 파싱"""
        try:
            items = data["response"]["body"]["items"]["item"]
            
            # 시간대별로 데이터 그룹화
            forecast_map = {}
            
            for item in items:
                fcst_date = item.get("fcstDate")
                fcst_time = item.get("fcstTime")
                category = item.get("category")
                value = item.get("fcstValue")
                
                key = f"{fcst_date}_{fcst_time}"
                if key not in forecast_map:
                    forecast_map[key] = {
                        "forecast_time": f"{fcst_date[:4]}-{fcst_date[4:6]}-{fcst_date[6:8]}T{fcst_time[:2]}:{fcst_time[2:]}:00",
                        "temperature": None,
                        "humidity": None,
                        "precipitation_probability": 0,
                        "precipitation": None,
                        "weather_status": "unknown",
                    }
                
                if category == "TMP":  # 1시간 기온
                    val = float(value)
                    forecast_map[key]["temperature"] = val if val > -50 else None
                elif category == "REH":  # 습도
                    val = float(value)
                    forecast_map[key]["humidity"] = int(val) if val >= 0 else None
                elif category == "POP":  # 강수확률
                    val = int(value)
                    forecast_map[key]["precipitation_probability"] = val if val >= 0 else 0
                elif category == "PCP":  # 강수량
                    if value != "강수없음":
                        try:
                            forecast_map[key]["precipitation"] = float(value.replace("mm", "").strip())
                        except ValueError:
                            pass
                elif category == "PTY":  # 강수형태
                    if value == "0":
                        forecast_map[key]["weather_status"] = "clear"
                    elif value in ["1", "2", "4", "5", "6"]:
                        forecast_map[key]["weather_status"] = "rainy"
                    elif value in ["3", "7"]:
                        forecast_map[key]["weather_status"] = "snowy"
                elif category == "SKY":  # 하늘상태
                    if forecast_map[key]["weather_status"] == "unknown":
                        if value == "1":
                            forecast_map[key]["weather_status"] = "clear"
                        elif value in ["3", "4"]:
                            forecast_map[key]["weather_status"] = "cloudy"
            
            # 정렬 후 24시간분만 반환
            forecasts = sorted(forecast_map.values(), key=lambda x: x["forecast_time"])[:8]
            
            return {
                "grid_nx": grid_nx,
                "grid_ny": grid_ny,
                "base_date": base_date,
                "base_time": base_time,
                "forecasts": forecasts,
                "is_mock": False,
            }
            
        except (KeyError, TypeError, ValueError) as e:
            logger.error(f"Failed to parse forecast data: {e}")
            return None
    
    async def check_rain_status(
        self,
        grid_nx: int,
        grid_ny: int,
        panel_id: Optional[int] = None,
    ) -> dict:
        """
        우천 여부 확인
        
        현재 비가 오고 있는지, 곧 비가 올 예정인지 확인
        
        Args:
            grid_nx: 격자 X 좌표
            grid_ny: 격자 Y 좌표
            panel_id: 패널 ID
        
        Returns:
            dict: 우천 상태 정보
        """
        result = {
            "is_raining": False,
            "will_rain_soon": False,
            "rain_probability": 0,
            "message": "",
            "should_skip_alert": False,
        }
        
        # 현재 날씨 조회
        current = await self.get_ultra_srt_ncst(grid_nx, grid_ny, panel_id)
        if current:
            result["is_raining"] = current.get("is_raining", False)
        
        # 예보 조회 (3시간 이내 강수 확률)
        forecast = await self.get_vilage_fcst(grid_nx, grid_ny, panel_id)
        if forecast and forecast.get("forecasts"):
            # 3시간 이내 예보 확인
            for fc in forecast["forecasts"][:3]:
                prob = fc.get("precipitation_probability", 0)
                if prob > result["rain_probability"]:
                    result["rain_probability"] = prob
                if fc.get("weather_status") == "rainy":
                    result["will_rain_soon"] = True
        
        # 메시지 및 알림 스킵 여부 결정
        if result["is_raining"]:
            result["message"] = "현재 비가 오고 있습니다. 오염 탐지 알림이 일시 중지됩니다."
            result["should_skip_alert"] = True
        elif result["will_rain_soon"] or result["rain_probability"] >= 60:
            result["message"] = f"곧 비가 올 예정입니다 (강수확률 {result['rain_probability']}%). 잠시 후 탐지를 재개합니다."
            result["should_skip_alert"] = True
        else:
            result["message"] = "날씨가 좋습니다. 정상적으로 탐지가 진행됩니다."
        
        return result
    
    # ─────────────────────────────────────────────────────────────────────────
    # Mock 데이터 (API 키 없을 때)
    # ─────────────────────────────────────────────────────────────────────────
    
    def _get_mock_current_weather(self, grid_nx: int, grid_ny: int) -> dict:
        """Mock 현재 날씨 데이터"""
        return {
            "grid_nx": grid_nx,
            "grid_ny": grid_ny,
            "temperature": 15.5,
            "humidity": 65,
            "precipitation": 0,
            "precipitation_type": "없음",
            "wind_speed": 2.5,
            "wind_direction": "SW",
            "weather_status": "clear",
            "is_raining": False,
            "observed_at": datetime.now().isoformat(),
            "is_mock": True,
        }
    
    def _get_mock_forecast(self, grid_nx: int, grid_ny: int) -> dict:
        """Mock 예보 데이터"""
        now = datetime.now()
        forecasts = []
        
        for i in range(8):
            fc_time = now + timedelta(hours=(i + 1) * 3)
            forecasts.append({
                "forecast_time": fc_time.isoformat(),
                "temperature": 15.0 + (i % 5),
                "humidity": 60 + (i * 2),
                "precipitation_probability": 10 + (i * 5),
                "precipitation": None,
                "weather_status": "clear" if i < 4 else "cloudy",
            })
        
        return {
            "grid_nx": grid_nx,
            "grid_ny": grid_ny,
            "base_date": now.strftime("%Y%m%d"),
            "base_time": "0500",
            "forecasts": forecasts,
            "is_mock": True,
        }

    async def get_short_term_forecast(
        self,
        nx: int,
        ny: int,
        panel_id: Optional[int] = None,
    ) -> Optional[dict]:
        """
        내일(또는 다음 날) 날씨 예보 조회
        
        AI 브리핑에서 사용하기 위한 간단한 예보 정보
        
        Args:
            nx: 격자 X 좌표
            ny: 격자 Y 좌표
            panel_id: 패널 ID (캐싱용)
        
        Returns:
            dict: {sky: "맑음/흐림/...", pop: 강수확률, tmp: 기온} 또는 None
        """
        # 단기예보 조회
        forecast_data = await self.get_vilage_fcst(nx, ny, panel_id)
        
        if not forecast_data or not forecast_data.get("forecasts"):
            logger.warning("No forecast data available")
            return None
        
        forecasts = forecast_data["forecasts"]
        is_mock = forecast_data.get("is_mock", False)
        
        # 내일의 예보 찾기 (12시 ~ 15시 사이)
        tomorrow = datetime.now() + timedelta(days=1)
        tomorrow_date_str = tomorrow.strftime("%Y-%m-%d")
        
        tomorrow_forecast = None
        for fc in forecasts:
            fc_time = fc.get("forecast_time", "")
            if tomorrow_date_str in fc_time:
                # 오후 시간대 예보 우선 선택
                hour = int(fc_time[11:13]) if len(fc_time) >= 13 else 0
                if 12 <= hour <= 15:
                    tomorrow_forecast = fc
                    break
                elif tomorrow_forecast is None:
                    tomorrow_forecast = fc
        
        # 내일 예보가 없으면 첫 번째 예보 사용
        if tomorrow_forecast is None and forecasts:
            tomorrow_forecast = forecasts[0]
        
        if tomorrow_forecast:
            weather_status = tomorrow_forecast.get("weather_status", "clear")
            sky_map = {
                "clear": "맑음",
                "cloudy": "구름많음", 
                "rainy": "비",
                "snowy": "눈",
                "unknown": "맑음",
            }
            
            return {
                "sky": sky_map.get(weather_status, "맑음"),
                "pop": tomorrow_forecast.get("precipitation_probability", 0),
                "tmp": tomorrow_forecast.get("temperature"),
                "is_mock": is_mock,
            }
        
        return None


    # ─────────────────────────────────────────────────────────────────────────
    # 스마트 인사이트 분석
    # ─────────────────────────────────────────────────────────────────────────

    async def analyze_weather_insights(
        self,
        grid_nx: int,
        grid_ny: int,
        panel_id: Optional[int] = None,
    ) -> dict:
        """
        날씨 데이터를 분석하여 스마트 관리 인사이트 생성
        
        자연 세척 추천, 제설 작업 알림, 발전 효율 저하 경고 등
        행동 가능한 인사이트(Actionable Insight) 제공
        
        Args:
            grid_nx: 격자 X 좌표
            grid_ny: 격자 Y 좌표
            panel_id: 패널 ID
        
        Returns:
            dict: 인사이트 분석 결과
        """
        insights = []
        
        # 현재 날씨 조회
        current = await self.get_ultra_srt_ncst(grid_nx, grid_ny, panel_id)
        forecast = await self.get_vilage_fcst(grid_nx, grid_ny, panel_id)
        
        result = {
            "current_temperature": current.get("temperature") if current else None,
            "current_weather_status": current.get("weather_status") if current else None,
            "is_raining": current.get("is_raining", False) if current else False,
            "is_mock": current.get("is_mock", False) or forecast.get("is_mock", False) if current and forecast else True,
            "insights": insights,
            "forecast_summary": None,
            "analyzed_at": datetime.now().isoformat(),
        }
        
        if not current or not forecast:
            logger.warning("Weather data unavailable for insight analysis")
            insights.append({
                "type": "alert",
                "level": "info",
                "message": "현재 날씨 정보를 가져올 수 없습니다.",
                "action_item": "잠시 후 다시 시도해 주세요.",
                "icon": "cloud_off",
            })
            return result
        
        # ─────────────────────────────────────────────────────────────────────
        # 1. 현재 날씨 상태 분석
        # ─────────────────────────────────────────────────────────────────────
        
        precipitation_type = current.get("precipitation_type", "없음")
        is_raining = current.get("is_raining", False)
        is_snowing = precipitation_type in ["눈", "눈날림", "빗방울눈날림", "비/눈"]
        
        # 현재 눈이 오는 경우
        if is_snowing:
            insights.append({
                "type": "maintenance",
                "level": "action_required",
                "message": f"현재 {precipitation_type}이(가) 오고 있습니다. 패널 위에 눈이 쌓일 수 있습니다.",
                "action_item": "발전 효율 저하를 막기 위해 제설 일정을 계획하세요.",
                "icon": "ac_unit",
            })
        
        # 현재 비가 오는 경우
        if is_raining:
            insights.append({
                "type": "cleaning",
                "level": "info",
                "message": "현재 비가 오고 있어 패널이 자연 세척 중입니다.",
                "action_item": "별도의 청소 작업은 불필요합니다.",
                "icon": "water_drop",
            })
        
        # ─────────────────────────────────────────────────────────────────────
        # 2. 예보 기반 인사이트 분석
        # ─────────────────────────────────────────────────────────────────────
        
        forecasts = forecast.get("forecasts", [])
        
        # 24시간 내 강수 예보 분석
        rain_forecast_times = []
        snow_forecast_times = []
        cloudy_hours = 0
        max_rain_prob = 0
        total_expected_precipitation = 0
        
        for fc in forecasts:
            weather_status = fc.get("weather_status", "unknown")
            rain_prob = fc.get("precipitation_probability", 0)
            precipitation = fc.get("precipitation") or 0
            
            if rain_prob > max_rain_prob:
                max_rain_prob = rain_prob
            
            total_expected_precipitation += precipitation
            
            if weather_status == "rainy" or rain_prob >= 60:
                rain_forecast_times.append(fc.get("forecast_time", ""))
            
            if weather_status == "snowy":
                snow_forecast_times.append(fc.get("forecast_time", ""))
            
            if weather_status in ["cloudy", "rainy", "snowy"]:
                cloudy_hours += 3  # 3시간 단위 예보
        
        # 자연 세척 추천 (내일 비 예보 시)
        if rain_forecast_times and not is_raining:
            first_rain_time = rain_forecast_times[0]
            try:
                rain_dt = datetime.fromisoformat(first_rain_time.replace("Z", "+00:00"))
                time_until_rain = rain_dt - datetime.now()
                hours_until = time_until_rain.total_seconds() / 3600
                
                if 6 <= hours_until <= 48:
                    # 많은 양의 비가 예상되는 경우
                    if total_expected_precipitation >= 5 or max_rain_prob >= 70:
                        insights.append({
                            "type": "cleaning",
                            "level": "info",
                            "message": f"약 {int(hours_until)}시간 후 비 예보가 있습니다 (강수확률 {max_rain_prob}%).",
                            "action_item": "오늘 패널 청소는 권장하지 않습니다. 비로 인한 자연 세척 효과가 기대됩니다.",
                            "icon": "eco",
                        })
                    else:
                        insights.append({
                            "type": "cleaning",
                            "level": "info",
                            "message": f"약 {int(hours_until)}시간 후 비 예보가 있습니다 (강수확률 {max_rain_prob}%).",
                            "action_item": "가벼운 비 예보입니다. 오염이 심할 경우 청소를 진행해도 좋습니다.",
                            "icon": "cloud",
                        })
            except (ValueError, TypeError) as e:
                logger.warning(f"Failed to parse rain forecast time: {e}")
        
        # 눈 예보 시 제설 작업 알림
        if snow_forecast_times:
            insights.append({
                "type": "maintenance",
                "level": "warning",
                "message": "24시간 내 눈 예보가 있습니다.",
                "action_item": "눈이 온 후 패널 위 눈을 제거해 주세요. 발전 효율 저하를 방지할 수 있습니다.",
                "icon": "snowing",
            })
        
        # 발전 효율 저하 경고 (장시간 흐림/우천)
        if cloudy_hours >= 12:
            insights.append({
                "type": "efficiency",
                "level": "warning",
                "message": f"향후 {cloudy_hours}시간 동안 흐리거나 우천이 예상됩니다.",
                "action_item": "기상 악화로 인해 오늘 예상 발전량이 평소보다 낮을 수 있습니다.",
                "icon": "cloud_queue",
            })
        
        # ─────────────────────────────────────────────────────────────────────
        # 3. 기온 관련 인사이트
        # ─────────────────────────────────────────────────────────────────────
        
        current_temp = current.get("temperature")
        if current_temp is not None:
            # 고온 경고 (패널 효율 저하)
            if current_temp >= 35:
                insights.append({
                    "type": "efficiency",
                    "level": "warning",
                    "message": f"현재 기온이 {current_temp}°C로 매우 높습니다.",
                    "action_item": "고온으로 인해 패널 효율이 저하될 수 있습니다. 통풍이 잘 되는지 확인하세요.",
                    "icon": "thermostat",
                })
            
            # 동결 주의 (겨울철 관리)
            if current_temp <= -5:
                insights.append({
                    "type": "maintenance",
                    "level": "warning",
                    "message": f"현재 기온이 {current_temp}°C로 매우 낮습니다.",
                    "action_item": "결빙에 주의하세요. 케이블 및 연결부 점검을 권장합니다.",
                    "icon": "severe_cold",
                })
        
        # ─────────────────────────────────────────────────────────────────────
        # 4. 풍속 관련 인사이트
        # ─────────────────────────────────────────────────────────────────────
        
        wind_speed = current.get("wind_speed")
        if wind_speed is not None and wind_speed >= 10:
            level = "action_required" if wind_speed >= 15 else "warning"
            insights.append({
                "type": "alert",
                "level": level,
                "message": f"현재 풍속이 {wind_speed}m/s로 강합니다.",
                "action_item": "강풍으로 인한 패널 손상에 주의하세요. 고정 상태를 확인하세요.",
                "icon": "air",
            })
        
        # ─────────────────────────────────────────────────────────────────────
        # 5. 예보 요약 생성
        # ─────────────────────────────────────────────────────────────────────
        
        if forecasts:
            summary_parts = []
            if rain_forecast_times:
                summary_parts.append(f"비 예보 {len(rain_forecast_times)}건")
            if snow_forecast_times:
                summary_parts.append(f"눈 예보 {len(snow_forecast_times)}건")
            if cloudy_hours > 0:
                summary_parts.append(f"흐림 예상 {cloudy_hours}시간")
            
            if summary_parts:
                result["forecast_summary"] = "24시간 예보: " + ", ".join(summary_parts)
            else:
                result["forecast_summary"] = "24시간 예보: 맑은 날씨 예상"
        
        # ─────────────────────────────────────────────────────────────────────
        # 6. 맑은 날씨일 때 긍정적 메시지
        # ─────────────────────────────────────────────────────────────────────
        
        if not insights:
            insights.append({
                "type": "efficiency",
                "level": "info",
                "message": "현재 날씨가 좋아 발전에 최적의 조건입니다.",
                "action_item": "특별한 조치가 필요하지 않습니다. 정상 운영을 유지하세요.",
                "icon": "wb_sunny",
            })
        
        result["insights"] = insights
        return result

