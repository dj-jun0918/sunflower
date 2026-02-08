"""
Solar Eye Backend - Detection API Router

탐지 결과 관련 API 엔드포인트
"""

import logging
from datetime import date
from typing import Annotated, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, get_pagination, PaginationParams
from app.models.user import User
from app.schemas.common import PaginatedResponse, PaginationMeta, SuccessResponse
from app.schemas.detection import (
    DefectType,
    DetectionDetail,
    DetectionFilter,
    DetectionResponse,
    DetectionStats,
)
from app.services.detection_service import DetectionService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/detections", tags=["Detections"])


@router.get(
    "",
    response_model=PaginatedResponse[DetectionResponse],
    summary="탐지 이력 조회",
    description="탐지 결과 목록을 페이지네이션과 필터링을 적용하여 조회합니다.",
)
async def get_detections(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    pagination: Annotated[PaginationParams, Depends(get_pagination)],
    # 필터 파라미터
    panel_id: Annotated[
        Optional[int], 
        Query(alias="panelId", description="패널 ID 필터")
    ] = None,
    defect_type: Annotated[
        Optional[DefectType], 
        Query(alias="defectType", description="결함 유형 필터")
    ] = None,
    min_confidence: Annotated[
        Optional[float], 
        Query(alias="minConfidence", ge=0.0, le=1.0, description="최소 신뢰도")
    ] = None,
    start_date: Annotated[
        Optional[date], 
        Query(alias="startDate", description="시작 날짜")
    ] = None,
    end_date: Annotated[
        Optional[date], 
        Query(alias="endDate", description="종료 날짜")
    ] = None,
):
    """
    탐지 결과 목록 조회

    - 현재 사용자가 소유한 패널의 탐지 결과만 조회됩니다.
    - 필터 및 페이지네이션을 지원합니다.

    **필터 옵션:**
    - `panelId`: 특정 패널의 탐지 결과만 조회
    - `defectType`: 결함 유형 필터 (defect/soiling/normal)
    - `minConfidence`: 최소 신뢰도 이상의 결과만 조회
    - `startDate`, `endDate`: 날짜 범위 필터
    """
    # 필터 파라미터 생성
    filter_params = DetectionFilter(
        panel_id=panel_id,
        defect_type=defect_type,
        min_confidence=min_confidence,
        start_date=start_date,
        end_date=end_date,
    )

    detection_service = DetectionService(db)
    detections, total = await detection_service.get_detections(
        user_id=current_user.id,
        filter_params=filter_params,
        offset=pagination.offset,
        limit=pagination.limit,
    )

    # 응답 데이터 변환
    detection_list = [
        DetectionResponse(
            id=d.id,
            panel_id=d.panel_id,
            defect_type=d.defect_type,
            defect_subtype=d.defect_subtype,
            confidence=d.confidence,
            snapshot_url=d.snapshot_url,
            detected_at=d.detected_at,
            bbox=d.bbox,
        )
        for d in detections
    ]

    return PaginatedResponse(
        data=detection_list,
        pagination=PaginationMeta.create(
            page=pagination.page,
            page_size=pagination.size,
            total_items=total,
        ),
    )


@router.get(
    "/{detection_id}",
    response_model=SuccessResponse[DetectionDetail],
    summary="탐지 상세 조회",
    description="특정 탐지 결과의 상세 정보를 조회합니다.",
)
async def get_detection(
    detection_id: int,
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
):
    """
    탐지 결과 상세 조회

    - 탐지 ID로 특정 탐지 결과의 상세 정보를 조회합니다.
    - 바운딩 박스, 패널 정보 등 상세 정보가 포함됩니다.
    - 현재 사용자가 소유한 패널의 탐지 결과만 조회 가능합니다.
    """
    detection_service = DetectionService(db)
    detection = await detection_service.get_detection(
        detection_id=detection_id,
        user_id=current_user.id,
    )

    if not detection:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="탐지 결과를 찾을 수 없습니다.",
        )

    # DetectionDetail로 변환 (바운딩 박스 포함)
    detail = DetectionDetail.from_orm_with_bbox(detection)

    return SuccessResponse(
        message="탐지 결과 조회 성공",
        data=detail,
    )


@router.get(
    "/stats/summary",
    response_model=SuccessResponse[DetectionStats],
    summary="탐지 통계 조회",
    description="탐지 결과 통계를 조회합니다.",
)
async def get_detection_stats(
    current_user: Annotated[User, Depends(get_current_user)],
    db: Annotated[AsyncSession, Depends(get_db)],
    panel_id: Annotated[
        Optional[int], 
        Query(alias="panelId", description="패널 ID 필터")
    ] = None,
    start_date: Annotated[
        Optional[date], 
        Query(alias="startDate", description="시작 날짜")
    ] = None,
    end_date: Annotated[
        Optional[date], 
        Query(alias="endDate", description="종료 날짜")
    ] = None,
):
    """
    탐지 통계 조회

    - 전체 탐지 건수, 결함 유형별 건수, 평균 신뢰도를 조회합니다.
    - 패널 ID 또는 날짜 범위로 필터링할 수 있습니다.
    """
    detection_service = DetectionService(db)
    stats = await detection_service.get_detection_stats(
        user_id=current_user.id,
        panel_id=panel_id,
        start_date=start_date,
        end_date=end_date,
    )

    return SuccessResponse(
        message="탐지 통계 조회 성공",
        data=stats,
    )
