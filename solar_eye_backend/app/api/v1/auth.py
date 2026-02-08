"""
Solar Eye Backend - Authentication API Router

인증 관련 API 엔드포인트
"""

import logging
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import (
    LoginRequest,
    LoginResponse,
    UserResponse,
    UserUpdate,
    FCMTokenRequest,
    FCMTokenResponse,
)
from app.schemas.common import SuccessResponse
from app.services.auth_service import AuthService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post(
    "/login",
    response_model=SuccessResponse[LoginResponse],
    summary="소셜 로그인",
    description="Firebase ID Token을 검증하고 사용자를 등록/조회합니다.",
)
async def login(
    request: LoginRequest,
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    소셜 로그인 (Firebase 인증)
    
    - Firebase ID Token을 검증합니다.
    - 신규 사용자인 경우 자동으로 등록합니다.
    - 기존 사용자인 경우 로그인 시간을 업데이트합니다.
    """
    try:
        auth_service = AuthService(db)
        user, is_new_user = await auth_service.verify_and_get_or_create_user(
            id_token=request.id_token
        )
        
        return SuccessResponse(
            message="로그인 성공" if not is_new_user else "회원가입 및 로그인 성공",
            data=LoginResponse(
                user=UserResponse.model_validate(user),
                is_new_user=is_new_user,
            )
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )
    except Exception as e:
        logger.exception("Login failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="로그인 처리 중 오류가 발생했습니다.",
        )


@router.get(
    "/me",
    response_model=SuccessResponse[UserResponse],
    summary="현재 사용자 정보 조회",
    description="현재 로그인한 사용자의 정보를 조회합니다.",
)
async def get_me(
    current_user: Annotated[User, Depends(get_current_user)],
):
    """
    현재 사용자 정보 조회
    
    - Authorization 헤더에 Firebase ID Token이 필요합니다.
    - 인증된 사용자의 정보를 반환합니다.
    """
    return SuccessResponse(
        message="사용자 정보 조회 성공",
        data=UserResponse.model_validate(current_user),
    )


@router.patch(
    "/me",
    response_model=SuccessResponse[UserResponse],
    summary="현재 사용자 정보 수정",
    description="현재 로그인한 사용자의 정보를 수정합니다.",
)
async def update_me(
    request: UserUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    현재 사용자 정보 수정
    
    수정 가능한 필드:
    - display_name: 표시 이름
    - photo_url: 프로필 이미지 URL
    - notification_enabled: 알림 활성화 여부
    """
    auth_service = AuthService(db)
    updated_user = await auth_service.update_user(
        user=current_user,
        display_name=request.display_name,
        photo_url=request.photo_url,
        notification_enabled=request.notification_enabled,
    )
    
    return SuccessResponse(
        message="사용자 정보가 수정되었습니다.",
        data=UserResponse.model_validate(updated_user),
    )


@router.post(
    "/fcm-token",
    response_model=FCMTokenResponse,
    summary="FCM 토큰 등록",
    description="푸시 알림을 위한 FCM 토큰을 등록합니다.",
)
async def register_fcm_token(
    request: FCMTokenRequest,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    FCM 토큰 등록
    
    - Firebase Cloud Messaging 토큰을 서버에 저장합니다.
    - 푸시 알림 발송에 사용됩니다.
    """
    auth_service = AuthService(db)
    await auth_service.update_fcm_token(
        user=current_user,
        fcm_token=request.fcm_token,
    )
    
    return FCMTokenResponse(
        success=True,
        message="FCM 토큰이 등록되었습니다.",
    )
