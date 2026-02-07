"""
Solar Eye Backend - API Dependencies

FastAPI 의존성 주입 함수 모음
"""

from typing import Optional

from fastapi import Depends
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.redis import get_redis
from app.core.security import (
    TokenPayload,
    get_current_user,
    get_current_user_optional,
    get_token_payload,
)
from app.db.session import get_db
from app.models.user import User

# =============================================================================
# Re-export for convenience (편의를 위한 재내보내기)
# =============================================================================

# DB 세션 의존성
# Usage: db: AsyncSession = Depends(get_db)
__all__ = [
    # Database
    "get_db",
    "AsyncSession",
    # Redis
    "get_redis",
    "get_redis_client",
    "Redis",
    # Authentication
    "get_token_payload",
    "get_current_user",
    "get_current_user_optional",
    "TokenPayload",
    "User",
]


# =============================================================================
# Redis Dependency with Optional Handling
# =============================================================================
async def get_redis_client() -> Optional[Redis]:
    """
    Redis 클라이언트 의존성
    
    Redis가 설정되지 않은 경우 None을 반환합니다.
    
    Usage:
        redis: Optional[Redis] = Depends(get_redis_client)
    """
    return await get_redis()


# =============================================================================
# Pagination Dependencies
# =============================================================================
class PaginationParams:
    """페이지네이션 파라미터"""
    
    def __init__(
        self,
        page: int = 1,
        size: int = 20,
    ):
        """
        Args:
            page: 페이지 번호 (1부터 시작)
            size: 페이지 크기 (최대 100)
        """
        self.page = max(1, page)
        self.size = min(max(1, size), 100)
        self.offset = (self.page - 1) * self.size
        self.limit = self.size


def get_pagination(
    page: int = 1,
    size: int = 20,
) -> PaginationParams:
    """
    페이지네이션 파라미터 의존성
    
    Usage:
        pagination: PaginationParams = Depends(get_pagination)
    """
    return PaginationParams(page=page, size=size)
