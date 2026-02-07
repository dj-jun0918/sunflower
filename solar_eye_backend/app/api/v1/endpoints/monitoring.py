from typing import List, Optional
import uuid

from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.services.analysis_service import AnalysisService
from app.schemas.monitoring import AnalysisSessionResponse, AnalysisResultResponse, AnalysisHistoryResponse

router = APIRouter()

@router.post(
    "/{facility_id}/cctv",
    response_model=AnalysisSessionResponse,
    status_code=status.HTTP_202_ACCEPTED
)
async def analyze_cctv_image(
    facility_id: int,
    image: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    CCTV 이미지 분석 요청
    """
    try:
        session = await AnalysisService.process_analysis(
            db=db,
            facility_id=facility_id,
            image_file=image,
            monitoring_type="cctv"
        )
        return session
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"분석 요청 처리 중 오류 발생: {str(e)}"
        )

@router.post(
    "/{facility_id}/drone",
    response_model=AnalysisSessionResponse,
    status_code=status.HTTP_202_ACCEPTED
)
async def analyze_drone_image(
    facility_id: int,
    image: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    드론 이미지 분석 요청
    """
    try:
        session = await AnalysisService.process_analysis(
            db=db,
            facility_id=facility_id,
            image_file=image,
            monitoring_type="drone"
        )
        return session
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"분석 요청 처리 중 오류 발생: {str(e)}"
        )

@router.get(
    "/results/{analysis_id}",
    response_model=AnalysisResultResponse
)
async def get_analysis_result(
    analysis_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
):
    """
    분석 결과 상세 조회
    """
    result = await AnalysisService.get_analysis_result(db, analysis_id)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="분석 결과를 찾을 수 없습니다."
        )
    return result

@router.get(
    "/history/{facility_id}",
    response_model=List[AnalysisSessionResponse]
)
async def get_facility_history(
    facility_id: int,
    type: Optional[str] = Query(None, description="cctv 또는 drone (선택)"),
    db: AsyncSession = Depends(get_db)
):
    """
    시설 분석 이력 조회
    """
    sessions = await AnalysisService.get_facility_history(db, facility_id, type)
    return sessions
