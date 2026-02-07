"""
Solar Eye Backend - Core Module

Core 모듈 초기화 및 내보내기
"""

from app.core.firebase import (
    close_firebase,
    get_firebase_app,
    get_firebase_user,
    init_firebase,
    verify_firebase_token,
)
from app.core.redis import (
    CacheKeys,
    cache_delete,
    cache_delete_pattern,
    cache_get,
    cache_set,
    close_redis,
    get_redis,
    init_redis,
)
from app.core.security import (
    TokenPayload,
    get_current_user,
    get_current_user_optional,
    get_token_payload,
)
from app.core.exceptions import (
    APIException,
    BadRequestError,
    ConflictError,
    ForbiddenError,
    NotFoundError,
    UnauthorizedError,
    register_exception_handlers,
)

__all__ = [
    # Firebase
    "init_firebase",
    "close_firebase",
    "get_firebase_app",
    "verify_firebase_token",
    "get_firebase_user",
    # Redis
    "init_redis",
    "close_redis",
    "get_redis",
    "cache_get",
    "cache_set",
    "cache_delete",
    "cache_delete_pattern",
    "CacheKeys",
    # Security
    "TokenPayload",
    "get_token_payload",
    "get_current_user",
    "get_current_user_optional",
    # Exceptions
    "APIException",
    "NotFoundError",
    "UnauthorizedError",
    "ForbiddenError",
    "BadRequestError",
    "ConflictError",
    "register_exception_handlers",
]
