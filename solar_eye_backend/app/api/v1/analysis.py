"""
Solar Eye Backend - Analysis API

이미지 분석 API 엔드포인트
"""

import logging
from typing import Annotated

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.models.user import User
from app.schemas.analysis import (
    AnalysisResultSchema,
    SnapshotAnalysisRequest,
    SnapshotAnalysisResponse,
)
from app.schemas.common import SuccessResponse
from app.services.analysis_service import AnalysisService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/analysis", tags=["Analysis"])


@router.post(
    "/image",
    response_model=SuccessResponse[AnalysisResultSchema],
    summary="이미지 분석",
    description="업로드된 이미지를 AI 파이프라인으로 분석하여 패널 상태를 반환합니다.",
)
async def analyze_image(
    file: Annotated[UploadFile, File(description="분석할 이미지 파일")],
    current_user: Annotated[User, Depends(get_current_user)],
):
    """
    단일 이미지 분석
    
    - 이미지 파일을 업로드하여 AI 분석 수행
    - 탐지된 패널 수, 결함/오염 통계, 개별 패널 정보 반환
    - DB에 저장하지 않음 (테스트/미리보기 용도)
    """
    # 파일 타입 검증
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미지 파일만 업로드 가능합니다."
        )
    
    try:
        # 파일 읽기
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="빈 파일입니다."
            )
        
        # 이미지 분석
        result = await AnalysisService.analyze_image_bytes(image_bytes)
        
        logger.info(
            f"사용자 {current_user.id}: 이미지 분석 완료 "
            f"(패널: {result.total_panels}, 결함: {result.defect_count}, 오염: {result.soiling_count})"
        )
        
        return SuccessResponse(
            message="이미지 분석 완료",
            data=result,
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"이미지 분석 중 오류: {e}", exc_info=True)  # 스택 트레이스 포함
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"이미지 분석 중 오류가 발생했습니다: {str(e)}"  # 에러 메시지 포함
        )


@router.post(
    "/snapshot",
    response_model=SuccessResponse[SnapshotAnalysisResponse],
    summary="패널 스냅샷 분석 및 저장",
    description="특정 패널의 스냅샷을 분석하고 결과를 DB에 저장합니다.",
)
async def analyze_snapshot(
    file: Annotated[UploadFile, File(description="분석할 스냅샷 이미지")],
    panel_id: int,
    save_results: bool = True,
    send_alert: bool = True,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    패널 스냅샷 분석 및 저장
    
    - 특정 패널의 스냅샷 이미지를 분석
    - 결함/오염 탐지 결과를 DB에 저장
    - 결함 발견 시 사용자에게 알림 전송
    """
    # 파일 타입 검증
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미지 파일만 업로드 가능합니다."
        )
    
    try:
        # 파일 읽기
        image_bytes = await file.read()
        
        if len(image_bytes) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="빈 파일입니다."
            )
        
        # 스냅샷 분석
        analysis_result, saved_ids, alert_sent = await AnalysisService.analyze_panel_snapshot(
            db=db,
            panel_id=panel_id,
            image_bytes=image_bytes,
            save_results=save_results,
            send_alert=send_alert,
        )
        
        logger.info(
            f"사용자 {current_user.id}: 패널 {panel_id} 스냅샷 분석 완료 "
            f"(저장: {len(saved_ids) if saved_ids else 0}건, 알림: {alert_sent})"
        )
        
        response = SnapshotAnalysisResponse(
            panel_id=panel_id,
            analysis_result=analysis_result,
            saved_detection_ids=saved_ids,
            alert_sent=alert_sent,
        )
        
        return SuccessResponse(
            message="스냅샷 분석 완료",
            data=response,
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"스냅샷 분석 중 오류: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="스냅샷 분석 중 오류가 발생했습니다."
        )
