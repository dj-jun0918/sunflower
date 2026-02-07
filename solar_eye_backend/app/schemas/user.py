"""
Solar Eye Backend - User Schemas

사용자 관련 Pydantic 스키마 정의
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class AuthProvider(str, Enum):
    """인증 제공자 열거형"""
    GOOGLE = "google"
    APPLE = "apple"


# ─────────────────────────────────────────────────────────────────────────────
# 기본 사용자 스키마
# ─────────────────────────────────────────────────────────────────────────────

class UserBase(BaseModel):
    """사용자 기본 스키마"""
    
    email: EmailStr = Field(..., description="이메일 주소")
    display_name: Optional[str] = Field(
        None, 
        max_length=100,
        alias="displayName",
        description="표시 이름"
    )
    photo_url: Optional[str] = Field(
        None, 
        alias="photoUrl",
        description="프로필 이미지 URL"
    )
    provider: AuthProvider = Field(
        default=AuthProvider.GOOGLE, 
        description="인증 제공자"
    )

    model_config = ConfigDict(populate_by_name=True)


class UserCreate(UserBase):
    """사용자 생성 요청 스키마"""
    
    firebase_uid: str = Field(
        ..., 
        min_length=1,
        max_length=128,
        alias="firebaseUid",
        description="Firebase UID"
    )


class UserUpdate(BaseModel):
    """사용자 정보 수정 요청 스키마"""
    
    display_name: Optional[str] = Field(
        None, 
        max_length=100,
        alias="displayName",
        description="표시 이름"
    )
    photo_url: Optional[str] = Field(
        None, 
        alias="photoUrl",
        description="프로필 이미지 URL"
    )
    notification_enabled: Optional[bool] = Field(
        None, 
        alias="notificationEnabled",
        description="푸시 알림 활성화 여부"
    )

    model_config = ConfigDict(populate_by_name=True)


class UserResponse(BaseModel):
    """사용자 정보 응답 스키마"""
    
    id: int = Field(..., description="사용자 ID")
    email: EmailStr = Field(..., description="이메일 주소")
    display_name: Optional[str] = Field(
        None, 
        alias="displayName",
        description="표시 이름"
    )
    photo_url: Optional[str] = Field(
        None, 
        alias="photoUrl",
        description="프로필 이미지 URL"
    )
    provider: str = Field(..., description="인증 제공자")
    notification_enabled: bool = Field(
        ..., 
        alias="notificationEnabled",
        description="푸시 알림 활성화 여부"
    )
    is_active: bool = Field(
        ..., 
        alias="isActive",
        description="계정 활성화 상태"
    )
    created_at: datetime = Field(
        ..., 
        alias="createdAt",
        description="계정 생성일시"
    )
    last_login_at: Optional[datetime] = Field(
        None, 
        alias="lastLoginAt",
        description="마지막 로그인 일시"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


# ─────────────────────────────────────────────────────────────────────────────
# 인증 관련 스키마
# ─────────────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    """로그인 요청 스키마 (Firebase ID Token)"""
    
    id_token: str = Field(
        ..., 
        min_length=1,
        alias="idToken",
        description="Firebase ID Token"
    )

    model_config = ConfigDict(populate_by_name=True)


class LoginResponse(BaseModel):
    """로그인 응답 스키마"""
    
    user: UserResponse = Field(..., description="사용자 정보")
    is_new_user: bool = Field(
        ..., 
        alias="isNewUser",
        description="신규 사용자 여부"
    )

    model_config = ConfigDict(populate_by_name=True)


class FCMTokenRequest(BaseModel):
    """FCM 토큰 등록 요청 스키마"""
    
    fcm_token: str = Field(
        ..., 
        min_length=1,
        alias="fcmToken",
        description="FCM 토큰"
    )

    model_config = ConfigDict(populate_by_name=True)

    @field_validator("fcm_token")
    @classmethod
    def validate_fcm_token(cls, v: str) -> str:
        """FCM 토큰 유효성 검사"""
        if not v or len(v.strip()) == 0:
            raise ValueError("FCM 토큰은 비어있을 수 없습니다")
        return v.strip()


class FCMTokenResponse(BaseModel):
    """FCM 토큰 등록 응답 스키마"""
    
    success: bool = Field(default=True, description="등록 성공 여부")
    message: str = Field(
        default="FCM 토큰이 등록되었습니다", 
        description="응답 메시지"
    )


# ─────────────────────────────────────────────────────────────────────────────
# Firebase 토큰 정보
# ─────────────────────────────────────────────────────────────────────────────

class FirebaseUserInfo(BaseModel):
    """Firebase 토큰에서 추출한 사용자 정보"""
    
    uid: str = Field(..., description="Firebase UID")
    email: Optional[str] = Field(None, description="이메일")
    name: Optional[str] = Field(None, description="이름")
    picture: Optional[str] = Field(None, description="프로필 이미지 URL")
    provider: Optional[str] = Field(None, description="인증 제공자")
