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

class AnalysisResultResponse(AnalysisSessionResponse):
    detections: List[DetectionResponse] = []
    
    model_config = ConfigDict(from_attributes=True)

class AnalysisHistoryResponse(BaseModel):
    sessions: List[AnalysisSessionResponse]
