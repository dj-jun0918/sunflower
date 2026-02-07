"""
Solar Eye Backend - Panel API Router

패널 관련 API 엔드포인트
"""

import logging
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, get_redis_client, PaginationParams, get_pagination
from app.models.user import User
from app.schemas.common import SuccessResponse, PaginatedResponse, PaginationMeta, MessageResponse
from app.schemas.panel import (
    PanelCreate,
    PanelUpdate,
    PanelResponse,
    PanelDetail,
    PanelStatusResponse,
    PanelStatus,
)
from app.services.panel_service import PanelService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/panels", tags=["Panels"])


@router.get(
    "",
    response_model=PaginatedResponse[PanelResponse],
    summary="패널 목록 조회",
    description="현재 사용자의 패널 목록을 조회합니다.",
)
async def get_panels(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    pagination: Annotated[PaginationParams, Depends(get_pagination)],
    status: Optional[str] = Query(None, description="상태 필터 (active/inactive/error/maintenance)"),
    search: Optional[str] = Query(None, description="검색어 (이름, 위치)"),
):
    """
    패널 목록 조회
    
    - 페이지네이션 지원
    - 상태 필터링 지원
    - 이름/위치 검색 지원
    """
    panel_service = PanelService(db)
    panels, total = await panel_service.get_panels(
        user_id=current_user.id,
        status=status,
        search=search,
        offset=pagination.offset,
        limit=pagination.limit,
    )
    
    return PaginatedResponse(
        data=[PanelResponse.model_validate(p) for p in panels],
        pagination=PaginationMeta.create(
            page=pagination.page,
            page_size=pagination.size,
            total_items=total,
        ),
    )


@router.post(
    "",
    response_model=SuccessResponse[PanelDetail],
    status_code=status.HTTP_201_CREATED,
    summary="패널 등록",
    description="새로운 패널을 등록합니다.",
)
async def create_panel(
    data: PanelCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    패널 등록
    
    - RTSP URL은 rtsp:// 또는 rtsps://로 시작해야 합니다.
    - 위경도 입력 시 기상청 격자 좌표가 자동 계산됩니다.
    """
    try:
        panel_service = PanelService(db)
        panel = await panel_service.create_panel(
            user_id=current_user.id,
            data=data,
        )
        
        return SuccessResponse(
            message="패널이 등록되었습니다.",
            data=PanelDetail.model_validate(panel),
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get(
    "/{panel_id}",
    response_model=SuccessResponse[PanelDetail],
    summary="패널 상세 조회",
    description="패널의 상세 정보를 조회합니다.",
)
async def get_panel(
    panel_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """패널 상세 조회"""
    panel_service = PanelService(db)
    panel = await panel_service.get_panel(panel_id, current_user.id)
    
    if not panel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없습니다.",
        )
    
    return SuccessResponse(
        message="패널 조회 성공",
        data=PanelDetail.model_validate(panel),
    )


@router.put(
    "/{panel_id}",
    response_model=SuccessResponse[PanelDetail],
    summary="패널 수정",
    description="패널 정보를 수정합니다.",
)
async def update_panel(
    panel_id: int,
    data: PanelUpdate,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    redis: Annotated[Optional[Redis], Depends(get_redis_client)],
):
    """패널 정보 수정"""
    panel_service = PanelService(db, redis)
    panel = await panel_service.get_panel(panel_id, current_user.id)
    
    if not panel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없습니다.",
        )
    
    try:
        updated_panel = await panel_service.update_panel(panel, data)
        
        return SuccessResponse(
            message="패널이 수정되었습니다.",
            data=PanelDetail.model_validate(updated_panel),
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.delete(
    "/{panel_id}",
    response_model=MessageResponse,
    summary="패널 삭제",
    description="패널을 삭제합니다. 관련된 탐지 기록과 리포트도 함께 삭제됩니다.",
)
async def delete_panel(
    panel_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    redis: Annotated[Optional[Redis], Depends(get_redis_client)],
):
    """패널 삭제"""
    panel_service = PanelService(db, redis)
    panel = await panel_service.get_panel(panel_id, current_user.id)
    
    if not panel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없습니다.",
        )
    
    await panel_service.delete_panel(panel)
    
    return MessageResponse(
        success=True,
        message="패널이 삭제되었습니다.",
    )


@router.get(
    "/{panel_id}/status",
    response_model=SuccessResponse[PanelStatusResponse],
    summary="패널 실시간 상태 조회",
    description="패널의 실시간 상태와 오늘의 탐지 통계를 조회합니다.",
)
async def get_panel_status(
    panel_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    redis: Annotated[Optional[Redis], Depends(get_redis_client)],
):
    """
    패널 실시간 상태 조회
    
    - Redis 캐시를 활용한 빠른 조회
    - 오늘의 결함/오염 탐지 건수 포함
    """
    panel_service = PanelService(db, redis)
    panel = await panel_service.get_panel(panel_id, current_user.id)
    
    if not panel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="패널을 찾을 수 없습니다.",
        )
    
    status_data = await panel_service.get_panel_status(panel)
    
    return SuccessResponse(
        message="패널 상태 조회 성공",
        data=PanelStatusResponse(**status_data),
    )
