"""
Solar Eye Backend - RTSP Stream API

RTSP 스트림 제어 API 엔드포인트
"""

from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.panel import Panel
from app.ai.stream_processor import (
    get_stream_manager,
    StreamStatus,
    StreamConfig,
    FrameData,
)
from app.ai.pipeline import get_pipeline

router = APIRouter(prefix="/stream", tags=["Stream"])


# =============================================================================
# Schemas
# =============================================================================

class StreamStartRequest(BaseModel):
    """스트림 시작 요청"""
    rtsp_url: str = Field(..., description="RTSP 스트림 URL")
    fps: float = Field(default=1.0, ge=0.1, le=30.0, description="초당 프레임 수")


class StreamStatusResponse(BaseModel):
    """스트림 상태 응답"""
    panel_id: int
    status: str
    last_frame_time: Optional[datetime] = None
    frame_count: int = 0
    error_count: int = 0
    last_error: Optional[str] = None


class StreamStartResponse(BaseModel):
    """스트림 시작 응답"""
    message: str
    panel_id: int
    rtsp_url: str
    fps: float


class StreamStopResponse(BaseModel):
    """스트림 중지 응답"""
    message: str
    panel_id: int


class AllStreamsStatusResponse(BaseModel):
    """전체 스트림 상태 응답"""
    total_streams: int
    active_streams: int
    streams: list[StreamStatusResponse]


# =============================================================================
# Global frame processor callback
# =============================================================================

async def process_frame(frame_data: FrameData):
    """
    프레임 처리 콜백 - AI 파이프라인으로 분석
    
    TODO: 실제 구현 시 비동기로 처리하고 결과를 DB에 저장
    """
    try:
        pipeline = get_pipeline()
        # 분석 수행 (비동기로 처리하려면 별도 작업 큐 필요)
        # result = pipeline.analyze(frame_data.frame)
        # 결과 저장 및 알림 처리
        print(f"[Stream] Panel {frame_data.panel_id} - Frame {frame_data.frame_number}")
    except Exception as e:
        print(f"[Stream] Frame processing error: {e}")


# =============================================================================
# Endpoints
# =============================================================================

@router.post(
    "/panels/{panel_id}/start",
    response_model=StreamStartResponse,
    summary="RTSP 스트림 시작",
    description="패널의 RTSP 스트림을 시작하고 AI 분석을 수행합니다.",
)
async def start_stream(
    panel_id: int,
    request: StreamStartRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    RTSP 스트림 시작
    
    - panel_id: 패널 ID
    - rtsp_url: RTSP 스트림 URL (예: rtsp://192.168.1.100:554/stream)
    - fps: 초당 프레임 수 (기본 1fps)
    """
    # 패널 존재 확인
    panel = await db.get(Panel, panel_id)
    if not panel:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"패널 ID {panel_id}를 찾을 수 없습니다",
        )
    
    manager = get_stream_manager()
    
    # 이미 실행 중인지 확인
    existing_status = manager.get_stream_status(panel_id)
    if existing_status and existing_status.status in [
        StreamStatus.CONNECTED,
        StreamStatus.STREAMING,
        StreamStatus.CONNECTING,
    ]:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"패널 {panel_id}의 스트림이 이미 실행 중입니다",
        )
    
    # 스트림 시작
    await manager.start_stream(
        panel_id=panel_id,
        rtsp_url=request.rtsp_url,
        on_frame=lambda fd: print(f"Frame {fd.frame_number} from panel {fd.panel_id}"),
        fps=request.fps,
    )
    
    return StreamStartResponse(
        message="스트림이 시작되었습니다",
        panel_id=panel_id,
        rtsp_url=request.rtsp_url,
        fps=request.fps,
    )


@router.post(
    "/panels/{panel_id}/stop",
    response_model=StreamStopResponse,
    summary="RTSP 스트림 중지",
    description="패널의 RTSP 스트림을 중지합니다.",
)
async def stop_stream(
    panel_id: int,
    db: AsyncSession = Depends(get_db),
):
    """RTSP 스트림 중지"""
    manager = get_stream_manager()
    
    # 스트림 상태 확인
    stream_status = manager.get_stream_status(panel_id)
    if not stream_status:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"패널 {panel_id}의 활성 스트림이 없습니다",
        )
    
    # 스트림 중지
    await manager.stop_stream(panel_id)
    
    return StreamStopResponse(
        message="스트림이 중지되었습니다",
        panel_id=panel_id,
    )


@router.get(
    "/panels/{panel_id}/status",
    response_model=StreamStatusResponse,
    summary="스트림 상태 조회",
    description="패널의 RTSP 스트림 상태를 조회합니다.",
)
async def get_stream_status(
    panel_id: int,
):
    """스트림 상태 조회"""
    manager = get_stream_manager()
    
    stream_state = manager.get_stream_status(panel_id)
    if not stream_state:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"패널 {panel_id}의 스트림 정보가 없습니다",
        )
    
    return StreamStatusResponse(
        panel_id=panel_id,
        status=stream_state.status.value,
        last_frame_time=stream_state.last_frame_time,
        frame_count=stream_state.frame_count,
        error_count=stream_state.error_count,
        last_error=stream_state.last_error,
    )


@router.get(
    "/status",
    response_model=AllStreamsStatusResponse,
    summary="전체 스트림 상태 조회",
    description="모든 활성 RTSP 스트림의 상태를 조회합니다.",
)
async def get_all_streams_status():
    """전체 스트림 상태 조회"""
    manager = get_stream_manager()
    all_statuses = manager.get_all_statuses()
    
    streams = [
        StreamStatusResponse(
            panel_id=panel_id,
            status=state.status.value,
            last_frame_time=state.last_frame_time,
            frame_count=state.frame_count,
            error_count=state.error_count,
            last_error=state.last_error,
        )
        for panel_id, state in all_statuses.items()
    ]
    
    return AllStreamsStatusResponse(
        total_streams=len(streams),
        active_streams=manager.get_active_count(),
        streams=streams,
    )


@router.post(
    "/stop-all",
    summary="모든 스트림 중지",
    description="모든 활성 RTSP 스트림을 중지합니다.",
)
async def stop_all_streams():
    """모든 스트림 중지"""
    manager = get_stream_manager()
    await manager.stop_all()
    
    return {"message": "모든 스트림이 중지되었습니다"}
