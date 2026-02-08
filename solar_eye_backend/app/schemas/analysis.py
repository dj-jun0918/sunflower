"""
Solar Eye Backend - Analysis Schemas

이미지 분석 요청/응답 스키마
"""

from typing import List, Optional

from pydantic import Field

from app.schemas.common import BaseSchema


# ─────────────────────────────────────────────────────────────────────────────
# 분석 결과 스키마
# ─────────────────────────────────────────────────────────────────────────────

class BoundingBoxSchema(BaseSchema):
    """바운딩 박스 스키마"""
    
    x: int = Field(..., description="좌상단 X 좌표")
    y: int = Field(..., description="좌상단 Y 좌표")
    width: int = Field(..., description="박스 너비")
    height: int = Field(..., description="박스 높이")


class PanelDetectionSchema(BaseSchema):
    """패널 탐지 결과 스키마"""
    
    bbox: BoundingBoxSchema = Field(..., description="바운딩 박스")
    panel_confidence: float = Field(..., description="패널 탐지 신뢰도", ge=0.0, le=1.0)
    defect_type: str = Field(..., description="결함 유형 (normal/defect/soiling)")
    defect_subtype: Optional[str] = Field(None, description="결함 세부 유형 (crack/dust 등)")
    class_confidence: float = Field(..., description="분류 신뢰도", ge=0.0, le=1.0)
    raw_class_name: str = Field(..., description="원본 분류 클래스명")
    mask: Optional[str] = Field(None, description="세그멘테이션 마스크 (JSON Polygon String)")


class AnalysisResultSchema(BaseSchema):
    """이미지 분석 결과 스키마"""
    
    total_panels: int = Field(..., description="탐지된 총 패널 수")
    normal_count: int = Field(..., description="정상 패널 수")
    defect_count: int = Field(..., description="결함 패널 수")
    soiling_count: int = Field(..., description="오염 패널 수")
    detections: List[PanelDetectionSchema] = Field(
        default_factory=list,
        description="개별 패널 탐지 결과"
    )


class SnapshotAnalysisRequest(BaseSchema):
    """스냅샷 분석 요청 스키마"""
    
    panel_id: int = Field(..., description="패널 ID")
    save_results: bool = Field(
        default=True,
        description="결과를 DB에 저장할지 여부"
    )
    send_alert: bool = Field(
        default=True,
        description="결함 발견 시 알림 전송 여부"
    )


class SnapshotAnalysisResponse(BaseSchema):
    """스냅샷 분석 응답 스키마"""
    
    panel_id: int = Field(..., description="패널 ID")
    analysis_result: AnalysisResultSchema = Field(..., description="분석 결과")
    saved_detection_ids: Optional[List[int]] = Field(
        None,
        description="저장된 탐지 결과 ID 목록"
    )
    alert_sent: bool = Field(default=False, description="알림 전송 여부")
