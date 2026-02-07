"""
Solar Eye Backend - Security Module

Firebase 인증 기반 보안 및 의존성 함수
"""

import logging
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.config import settings
from app.core.firebase import verify_firebase_token
from app.db.session import get_db
from app.models.user import User

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

logger = logging.getLogger(__name__)

# HTTP Bearer 토큰 스키마
security = HTTPBearer(auto_error=False)


class TokenPayload:
    """토큰 페이로드 데이터 클래스"""
    
    def __init__(
        self,
        uid: str,
        email: Optional[str] = None,
        name: Optional[str] = None,
        picture: Optional[str] = None,
        provider: Optional[str] = None,
    ):
        self.uid = uid
        self.email = email
        self.name = name
        self.picture = picture
        self.provider = provider


async def get_token_payload(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
) -> TokenPayload:
    """
    Firebase ID Token 검증 및 페이로드 추출
    
    Args:
        credentials: HTTP Authorization 헤더의 Bearer 토큰
        
    Returns:
        TokenPayload: 검증된 토큰 정보
        
    Raises:
        HTTPException: 토큰이 없거나 유효하지 않은 경우
    """
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = credentials.credentials
    decoded = verify_firebase_token(token)
    
    if decoded is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Firebase 토큰에서 provider 정보 추출
    firebase_info = decoded.get("firebase", {})
    sign_in_provider = firebase_info.get("sign_in_provider", "unknown")
    
    # Provider 이름 정규화
    provider_map = {
        "google.com": "google",
        "apple.com": "apple",
        "password": "email",
    }
    provider = provider_map.get(sign_in_provider, sign_in_provider)
    
    return TokenPayload(
        uid=decoded["uid"],
        email=decoded.get("email"),
        name=decoded.get("name"),
        picture=decoded.get("picture"),
        provider=provider,
    )


async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    현재 인증된 사용자 조회
    
    Firebase UID로 DB에서 사용자를 조회합니다.
    사용자가 없으면 401 에러를 반환합니다.
    
    개발 환경(app_env=development)에서는 토큰 없이도 첫 번째 사용자를 반환합니다.
    
    Args:
        credentials: HTTP Authorization 헤더의 Bearer 토큰
        db: DB 세션
        
    Returns:
        User: 현재 인증된 사용자
        
    Raises:
        HTTPException: 사용자를 찾을 수 없는 경우
    """
    # 개발 모드에서 토큰이 없으면 첫 번째 사용자 반환
    if settings.is_development and credentials is None:
        logger.warning("⚠️ Development mode: Using first user for authentication bypass")
        result = await db.execute(select(User).where(User.is_active == True).limit(1))
        user = result.scalar_one_or_none()
        if user:
            return user
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No users in database. Please seed data first.",
        )
    
    # 인증 필수 (credentials 없으면 에러)
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Firebase 토큰 검증
    token = credentials.credentials
    decoded = verify_firebase_token(token)
    
    if decoded is None:
        # [Emergency Bypass] 개발 모드에서 토큰 검증 실패 시 첫 번째 사용자로 폴백
        if settings.is_development:
            logger.warning("⚠️ Invalid Token in Dev Mode: Falling back to first user")
            result = await db.execute(select(User).where(User.is_active == True).limit(1))
            user = result.scalar_one_or_none()
            if user:
                return user
                
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    result = await db.execute(
        select(User).where(User.firebase_uid == decoded["uid"])
    )
    user = result.scalar_one_or_none()
    
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found. Please login first.",
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated",
        )
    
    return user


async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    """
    현재 인증된 사용자 조회 (선택적)
    
    토큰이 없거나 유효하지 않은 경우 None을 반환합니다.
    공개 API에서 인증된 사용자 정보가 필요할 때 사용합니다.
    
    Args:
        credentials: HTTP Authorization 헤더의 Bearer 토큰
        db: DB 세션
        
    Returns:
        User: 현재 인증된 사용자 (없으면 None)
    """
    if credentials is None:
        return None
    
    token = credentials.credentials
    decoded = verify_firebase_token(token)
    
    if decoded is None:
        return None
    
    result = await db.execute(
        select(User).where(User.firebase_uid == decoded["uid"])
    )
    user = result.scalar_one_or_none()
    
    if user is None or not user.is_active:
        return None
    
    return user
