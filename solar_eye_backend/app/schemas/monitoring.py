from typing import List, Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.schemas.detection import DetectionResponse

class AnalysisSessionBase(BaseModel):
    panel_id: int
    type: str  # "cctv" or "drone"
    status: str  # "processing", "completed", "failed"
    original_image_url: Optional[str] = None

class AnalysisSessionCreate(AnalysisSessionBase):
    pass

class AnalysisSessionResponse(AnalysisSessionBase):
    id: UUID
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class CropImageSchema(BaseModel):
    """Crop된 패널 이미지 정보"""
    url: str  # Enhanced 이미지 URL
    mask_url: Optional[str] = None  # Mask 이미지 URL
    bbox: dict  # {x, y, width, height}
    defect_type: str
    confidence: float

class AnalysisResultResponse(AnalysisSessionResponse):
    detections: List[DetectionResponse] = []
    
    # CCTV 분석 전용 필드 (lssunflower 프론트엔드 호환용)
    enhanced_image_url: Optional[str] = None  # Real-ESRGAN 결과
    mask_image_url: Optional[str] = None  # SegFormer 마스크 컬러 이미지
    crop_images: List[CropImageSchema] = []  # Crop된 패널 이미지 목록
    
    model_config = ConfigDict(from_attributes=True)

class AnalysisHistoryResponse(BaseModel):
    sessions: List[AnalysisSessionResponse]
