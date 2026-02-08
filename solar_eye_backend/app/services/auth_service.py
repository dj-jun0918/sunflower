"""
Solar Eye Backend - Authentication Service

인증 관련 비즈니스 로직
"""

import logging
from datetime import datetime
from typing import Optional, Tuple

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.firebase import verify_firebase_token
from app.models.user import User

logger = logging.getLogger(__name__)


class AuthService:
    """인증 서비스 클래스"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def verify_and_get_or_create_user(
        self,
        id_token: str,
    ) -> Tuple[User, bool]:
        """
        Firebase ID Token 검증 및 사용자 조회/생성
        
        Args:
            id_token: Firebase ID Token
            
        Returns:
            Tuple[User, bool]: (사용자 객체, 신규 사용자 여부)
            
        Raises:
            ValueError: 토큰이 유효하지 않은 경우
        """
        # 토큰 검증
        decoded = verify_firebase_token(id_token)
        if decoded is None:
            raise ValueError("Invalid or expired token")
        
        uid = decoded["uid"]
        email = decoded.get("email")
        name = decoded.get("name")
        picture = decoded.get("picture")
        
        # Provider 정보 추출
        firebase_info = decoded.get("firebase", {})
        sign_in_provider = firebase_info.get("sign_in_provider", "unknown")
        provider_map = {
            "google.com": "google",
            "apple.com": "apple",
            "password": "email",
        }
        provider = provider_map.get(sign_in_provider, sign_in_provider)
        
        # 기존 사용자 조회
        result = await self.db.execute(
            select(User).where(User.firebase_uid == uid)
        )
        user = result.scalar_one_or_none()
        
        is_new_user = False
        
        if user is None:
            # 신규 사용자 생성
            user = User(
                firebase_uid=uid,
                email=email or f"{uid}@firebase.local",
                display_name=name,
                photo_url=picture,
                provider=provider,
                last_login_at=datetime.utcnow(),
            )
            self.db.add(user)
            await self.db.commit()
            await self.db.refresh(user)
            is_new_user = True
            logger.info(f"New user created: {user.email}")
        else:
            # 기존 사용자 로그인 시간 업데이트
            user.last_login_at = datetime.utcnow()
            # 사용자 정보 업데이트 (변경된 경우만)
            if name and user.display_name != name:
                user.display_name = name
            if picture and user.photo_url != picture:
                user.photo_url = picture
            await self.db.commit()
            await self.db.refresh(user)
            logger.info(f"User logged in: {user.email}")
        
        return user, is_new_user

    async def get_user_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        """
        Firebase UID로 사용자 조회
        
        Args:
            firebase_uid: Firebase UID
            
        Returns:
            User or None
        """
        result = await self.db.execute(
            select(User).where(User.firebase_uid == firebase_uid)
        )
        return result.scalar_one_or_none()

    async def update_user(
        self,
        user: User,
        display_name: Optional[str] = None,
        photo_url: Optional[str] = None,
        notification_enabled: Optional[bool] = None,
    ) -> User:
        """
        사용자 정보 업데이트
        
        Args:
            user: 업데이트할 사용자
            display_name: 표시 이름
            photo_url: 프로필 이미지 URL
            notification_enabled: 알림 활성화 여부
            
        Returns:
            업데이트된 사용자
        """
        if display_name is not None:
            user.display_name = display_name
        if photo_url is not None:
            user.photo_url = photo_url
        if notification_enabled is not None:
            user.notification_enabled = notification_enabled
        
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def update_fcm_token(self, user: User, fcm_token: str) -> User:
        """
        FCM 토큰 저장
        
        Args:
            user: 사용자
            fcm_token: FCM 토큰
            
        Returns:
            업데이트된 사용자
        """
        user.fcm_token = fcm_token
        await self.db.commit()
        await self.db.refresh(user)
        logger.info(f"FCM token updated for user: {user.email}")
        return user


# 의존성 주입을 위한 헬퍼 함수
async def get_auth_service(db: AsyncSession) -> AuthService:
    """AuthService 인스턴스 생성"""
    return AuthService(db)
