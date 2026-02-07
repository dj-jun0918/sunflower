"""
Solar Eye Backend - Redis Client Module

Redis 연결 및 캐시 관리
"""

import logging
from typing import Any, Optional

import redis.asyncio as redis
from redis.asyncio import Redis

from app.config import settings

logger = logging.getLogger(__name__)

# Redis 클라이언트 인스턴스
_redis_client: Optional[Redis] = None


# =============================================================================
# Cache Key Patterns (캐시 키 패턴)
# =============================================================================
class CacheKeys:
    """Redis 캐시 키 패턴 정의"""
    
    # 날씨 캐시 (1시간 TTL)
    WEATHER_CURRENT = "weather:current:{panel_id}"  # 현재 날씨
    WEATHER_FORECAST = "weather:forecast:{panel_id}"  # 단기 예보
    WEATHER_TTL = 3600  # 1시간
    
    # 패널 상태 캐시 (5분 TTL)
    PANEL_STATUS = "panel:status:{panel_id}"
    PANEL_STATUS_TTL = 300  # 5분
    
    # 사용자 세션 캐시 (24시간 TTL)
    USER_SESSION = "user:session:{user_id}"
    USER_SESSION_TTL = 86400  # 24시간
    
    # 탐지 결과 캐시 (10분 TTL)
    DETECTION_LATEST = "detection:latest:{panel_id}"
    DETECTION_TTL = 600  # 10분
    
    # 알림 읽지 않은 개수 캐시 (5분 TTL)
    ALERT_UNREAD_COUNT = "alert:unread:{user_id}"
    ALERT_UNREAD_TTL = 300  # 5분
    
    # 일간 리포트 캐시 (6시간 TTL)
    REPORT_DAILY = "report:daily:{panel_id}:{date}"
    REPORT_TTL = 21600  # 6시간
    
    @classmethod
    def weather_current(cls, panel_id: int) -> str:
        """현재 날씨 캐시 키"""
        return cls.WEATHER_CURRENT.format(panel_id=panel_id)
    
    @classmethod
    def weather_forecast(cls, panel_id: int) -> str:
        """단기 예보 캐시 키"""
        return cls.WEATHER_FORECAST.format(panel_id=panel_id)
    
    @classmethod
    def panel_status(cls, panel_id: int) -> str:
        """패널 상태 캐시 키"""
        return cls.PANEL_STATUS.format(panel_id=panel_id)
    
    @classmethod
    def user_session(cls, user_id: int) -> str:
        """사용자 세션 캐시 키"""
        return cls.USER_SESSION.format(user_id=user_id)
    
    @classmethod
    def detection_latest(cls, panel_id: int) -> str:
        """최신 탐지 결과 캐시 키"""
        return cls.DETECTION_LATEST.format(panel_id=panel_id)
    
    @classmethod
    def alert_unread(cls, user_id: int) -> str:
        """읽지 않은 알림 수 캐시 키"""
        return cls.ALERT_UNREAD_COUNT.format(user_id=user_id)
    
    @classmethod
    def report_daily(cls, panel_id: int, date: str) -> str:
        """일간 리포트 캐시 키"""
        return cls.REPORT_DAILY.format(panel_id=panel_id, date=date)


# =============================================================================
# Redis Connection Management
# =============================================================================
async def init_redis() -> Optional[Redis]:
    """
    Redis 클라이언트 초기화
    
    Returns:
        Redis: 연결된 Redis 클라이언트
        None: 연결 실패 시
    """
    global _redis_client
    
    if _redis_client is not None:
        return _redis_client
    
    try:
        _redis_client = redis.from_url(
            settings.redis_url,
            encoding="utf-8",
            decode_responses=True,
        )
        
        # 연결 테스트
        await _redis_client.ping()
        logger.info(f"Redis connected: {settings.redis_url}")
        return _redis_client
        
    except Exception as e:
        logger.error(f"Failed to connect to Redis: {e}")
        _redis_client = None
        return None


async def get_redis() -> Optional[Redis]:
    """
    Redis 클라이언트 반환
    
    FastAPI 의존성 주입에서 사용
    """
    global _redis_client
    return _redis_client


async def close_redis() -> None:
    """Redis 연결 종료"""
    global _redis_client
    
    if _redis_client is not None:
        try:
            await _redis_client.close()
            _redis_client = None
            logger.info("Redis connection closed")
        except Exception as e:
            logger.error(f"Failed to close Redis connection: {e}")


# =============================================================================
# Cache Helper Functions
# =============================================================================
async def cache_get(key: str) -> Optional[str]:
    """
    캐시에서 값 조회
    
    Args:
        key: 캐시 키
        
    Returns:
        str: 캐시된 값 (없으면 None)
    """
    if _redis_client is None:
        return None
        
    try:
        return await _redis_client.get(key)
    except Exception as e:
        logger.error(f"Redis GET error for key {key}: {e}")
        return None


async def cache_set(key: str, value: Any, ttl: int = 3600) -> bool:
    """
    캐시에 값 저장
    
    Args:
        key: 캐시 키
        value: 저장할 값
        ttl: TTL (초), 기본 1시간
        
    Returns:
        bool: 저장 성공 여부
    """
    if _redis_client is None:
        return False
        
    try:
        await _redis_client.set(key, value, ex=ttl)
        return True
    except Exception as e:
        logger.error(f"Redis SET error for key {key}: {e}")
        return False


async def cache_delete(key: str) -> bool:
    """
    캐시에서 값 삭제
    
    Args:
        key: 캐시 키
        
    Returns:
        bool: 삭제 성공 여부
    """
    if _redis_client is None:
        return False
        
    try:
        await _redis_client.delete(key)
        return True
    except Exception as e:
        logger.error(f"Redis DELETE error for key {key}: {e}")
        return False


async def cache_delete_pattern(pattern: str) -> int:
    """
    패턴과 일치하는 모든 키 삭제
    
    Args:
        pattern: 키 패턴 (예: "weather:*")
        
    Returns:
        int: 삭제된 키 수
    """
    if _redis_client is None:
        return 0
        
    try:
        keys = []
        async for key in _redis_client.scan_iter(match=pattern):
            keys.append(key)
        
        if keys:
            return await _redis_client.delete(*keys)
        return 0
    except Exception as e:
        logger.error(f"Redis DELETE PATTERN error for {pattern}: {e}")
        return 0
