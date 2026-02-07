"""
Solar Eye Backend - Alert API Router

알림 관련 API 엔드포인트
"""

import logging
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, get_pagination, PaginationParams
from app.models.user import User
from app.schemas.alert import (
    AlertFilter,
    AlertList,
    AlertListMeta,
    AlertResponse,
    AlertDetail,
    AlertType,
    MarkReadResponse,
)
from app.schemas.common import SuccessResponse
from app.services.alert_service import AlertService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/alerts", tags=["Alerts"])


@router.get(
    "",
    response_model=AlertList,
    summary="알림 목록 조회",
    description="사용자의 알림 목록을 조회합니다.",
)
async def get_alerts(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    pagination: Annotated[PaginationParams, Depends(get_pagination)],
    # 필터 파라미터
    alert_type: Annotated[
        Optional[AlertType],
        Query(alias="alertType", description="알림 유형 필터"),
    ] = None,
    is_read: Annotated[
        Optional[bool],
        Query(alias="isRead", description="읽음 여부 필터"),
    ] = None,
    panel_id: Annotated[
        Optional[int],
        Query(alias="panelId", description="패널 ID 필터"),
    ] = None,
):
    """
    알림 목록 조회

    - 현재 사용자의 알림 목록을 페이지네이션과 필터링을 적용하여 조회합니다.
    - 읽지 않은 알림 개수와 함께 반환됩니다.

    **필터 옵션:**
    - `alertType`: 알림 유형 필터 (defect/soiling/report/system/weather)
    - `isRead`: 읽음 여부 (true: 읽은 알림만, false: 안 읽은 알림만)
    - `panelId`: 특정 패널 관련 알림만 조회
    """
    # 필터 파라미터 생성
    filter_params = AlertFilter(
        alert_type=alert_type,
        is_read=is_read,
        panel_id=panel_id,
    )

    alert_service = AlertService(db)
    alerts, total_count, unread_count = await alert_service.get_alerts(
        user_id=current_user.id,
        filter_params=filter_params,
        offset=pagination.offset,
        limit=pagination.limit,
    )

    # 응답 데이터 변환
    alert_list = [
        AlertResponse(
            id=a.id,
            alert_type=a.alert_type,
            title=a.title,
            message=a.message,
            is_read=a.is_read,
            sent_at=a.sent_at,
            image_url=a.image_url,
            deep_link=a.deep_link,
            detection_id=a.detection_id,
        )
        for a in alerts
    ]

    return AlertList(
        alerts=alert_list,
        meta=AlertListMeta(
            total_count=total_count,
            unread_count=unread_count,
        ),
    )


@router.get(
    "/{alert_id}",
    response_model=SuccessResponse[AlertDetail],
    summary="알림 상세 조회",
    description="특정 알림의 상세 정보를 조회합니다.",
)
async def get_alert(
    alert_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    알림 상세 조회

    - 알림 ID로 특정 알림의 상세 정보를 조회합니다.
    - 탐지 결과와 연결된 경우 관련 정보도 포함됩니다.
    """
    alert_service = AlertService(db)
    alert = await alert_service.get_alert(
        alert_id=alert_id,
        user_id=current_user.id,
    )

    if not alert:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="알림을 찾을 수 없습니다.",
        )

    # 패널 이름 조회 (detection이 있는 경우)
    panel_name = None
    if alert.detection and alert.detection.panel:
        panel_name = alert.detection.panel.name

    detail = AlertDetail(
        id=alert.id,
        user_id=alert.user_id,
        alert_type=alert.alert_type,
        title=alert.title,
        message=alert.message,
        is_read=alert.is_read,
        sent_at=alert.sent_at,
        read_at=alert.read_at,
        image_url=alert.image_url,
        deep_link=alert.deep_link,
        detection_id=alert.detection_id,
        panel_name=panel_name,
    )

    return SuccessResponse(
        message="알림 조회 성공",
        data=detail,
    )


@router.put(
    "/{alert_id}/read",
    response_model=MarkReadResponse,
    summary="알림 읽음 처리",
    description="특정 알림을 읽음 처리합니다.",
)
async def mark_alert_as_read(
    alert_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    알림 읽음 처리

    - 특정 알림을 읽음 상태로 변경합니다.
    - 이미 읽은 알림인 경우에도 성공 응답을 반환합니다.
    """
    alert_service = AlertService(db)
    alert = await alert_service.mark_as_read(
        alert_id=alert_id,
        user_id=current_user.id,
    )

    if not alert:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="알림을 찾을 수 없습니다.",
        )

    return MarkReadResponse(
        success=True,
        message="알림을 읽음 처리했습니다.",
        read_count=1,
    )


@router.put(
    "/read-all",
    response_model=MarkReadResponse,
    summary="전체 알림 읽음 처리",
    description="모든 읽지 않은 알림을 읽음 처리합니다.",
)
async def mark_all_alerts_as_read(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    전체 알림 읽음 처리

    - 사용자의 모든 읽지 않은 알림을 읽음 상태로 변경합니다.
    - 읽음 처리된 알림 개수를 반환합니다.
    """
    alert_service = AlertService(db)
    updated_count = await alert_service.mark_all_as_read(user_id=current_user.id)

    return MarkReadResponse(
        success=True,
        message=f"{updated_count}개의 알림을 읽음 처리했습니다.",
        read_count=updated_count,
    )


@router.get(
    "/unread/count",
    response_model=SuccessResponse[dict],
    summary="읽지 않은 알림 개수",
    description="읽지 않은 알림의 개수를 조회합니다.",
)
async def get_unread_count(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    읽지 않은 알림 개수 조회

    - 사용자의 읽지 않은 알림 개수를 반환합니다.
    - 앱 내 알림 배지 표시에 활용할 수 있습니다.
    """
    alert_service = AlertService(db)
    unread_count = await alert_service.get_unread_count(user_id=current_user.id)

    return SuccessResponse(
        message="읽지 않은 알림 개수 조회 성공",
        data={"unreadCount": unread_count},
    )
