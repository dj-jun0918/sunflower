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
    """Crop???⑤꼸 ?대?吏 ?뺣낫"""
    url: str  # Enhanced ?대?吏 URL
    mask_url: Optional[str] = None  # Mask ?대?吏 URL
    bbox: dict  # {x, y, width, height}
    defect_type: str
    confidence: float

class AnalysisResultResponse(AnalysisSessionResponse):
    detections: List[DetectionResponse] = []
    
    # CCTV 遺꾩꽍 ?꾩슜 ?꾨뱶
    enhanced_image_url: Optional[str] = None  # Real-ESRGAN 寃곌낵
    mask_image_url: Optional[str] = None  # SegFormer 留덉뒪??而щ윭 ?대?吏
    crop_images: List[CropImageSchema] = []  # Crop???⑤꼸 ?대?吏 紐⑸줉
    
    model_config = ConfigDict(from_attributes=True)

class AnalysisHistoryResponse(BaseModel):
    sessions: List[AnalysisSessionResponse]
