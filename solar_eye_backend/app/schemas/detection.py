"""
Solar Eye Backend - Detection Schemas

탐지 결과 관련 Pydantic 스키마 정의
"""

from datetime import datetime, date
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class DefectType(str, Enum):
    """결함 유형 열거형"""
    DEFECT = "defect"       # 물리적 결함
    SOILING = "soiling"     # 오염
    NORMAL = "normal"       # 정상


class DefectSubtype(str, Enum):
    """결함 세부 유형 열거형"""
    # Defect 세부 유형
    CRACK = "crack"              # 크랙
    HOTSPOT = "hotspot"          # 핫스팟
    BROKEN_CELL = "broken_cell"  # 셀 파손
    DELAMINATION = "delamination"  # 박리
    
    # Soiling 세부 유형
    DUST = "dust"                # 먼지
    BIRD_DROP = "bird_drop"      # 조류 배설물
    LEAF = "leaf"                # 낙엽
    SNOW = "snow"                # 눈
    
    # 기타
    UNKNOWN = "unknown"          # 알 수 없음


# ─────────────────────────────────────────────────────────────────────────────
# 바운딩 박스 스키마
# ─────────────────────────────────────────────────────────────────────────────

class BoundingBox(BaseModel):
    """바운딩 박스 스키마"""
    
    x: int = Field(..., ge=0, description="X 좌표")
    y: int = Field(..., ge=0, description="Y 좌표")
    width: int = Field(..., ge=0, description="너비")
    height: int = Field(..., ge=0, description="높이")

    @property
    def area(self) -> int:
        """바운딩 박스 면적"""
        return self.width * self.height

    @property
    def center(self) -> tuple[float, float]:
        """바운딩 박스 중심점"""
        return (self.x + self.width / 2, self.y + self.height / 2)


# ─────────────────────────────────────────────────────────────────────────────
# 탐지 결과 스키마
# ─────────────────────────────────────────────────────────────────────────────

class DetectionBase(BaseModel):
    """탐지 결과 기본 스키마"""
    
    defect_type: DefectType = Field(
        ..., 
        alias="defectType",
        description="결함 유형"
    )
    defect_subtype: Optional[DefectSubtype] = Field(
        None, 
        alias="defectSubtype",
        description="결함 세부 유형"
    )
    confidence: float = Field(
        ..., 
        ge=0.0, 
        le=1.0,
        description="탐지 신뢰도 (0.0 ~ 1.0)"
    )

    model_config = ConfigDict(populate_by_name=True)


class DetectionCreate(DetectionBase):
    """탐지 결과 생성 스키마 (내부 사용)"""
    
    panel_id: int = Field(..., alias="panelId", description="패널 ID")
    bbox_x: int = Field(..., ge=0, alias="bboxX", description="바운딩 박스 X")
    bbox_y: int = Field(..., ge=0, alias="bboxY", description="바운딩 박스 Y")
    bbox_width: int = Field(..., ge=0, alias="bboxWidth", description="바운딩 박스 너비")
    bbox_height: int = Field(..., ge=0, alias="bboxHeight", description="바운딩 박스 높이")
    snapshot_url: Optional[str] = Field(
        None, 
        alias="snapshotUrl",
        description="스냅샷 URL"
    )
    frame_number: Optional[int] = Field(
        None, 
        alias="frameNumber",
        description="프레임 번호"
    )
    area_percentage: Optional[float] = Field(
        None, 
        ge=0, 
        le=100,
        alias="areaPercentage",
        description="결함 영역 비율 (%)"
    )
    mask: Optional[str] = Field(
        None,
        description="세그멘테이션 마스크 (JSON Polygon String)"
    )


class DetectionResponse(BaseModel):
    """탐지 결과 응답 스키마 (목록용)"""
    
    id: int = Field(..., description="탐지 ID")
    panel_id: int = Field(..., alias="panelId", description="패널 ID")
    defect_type: str = Field(..., alias="defectType", description="결함 유형")
    defect_subtype: Optional[str] = Field(
        None, 
        alias="defectSubtype",
        description="결함 세부 유형"
    )
    confidence: float = Field(..., description="신뢰도")
    snapshot_url: Optional[str] = Field(
        None, 
        alias="snapshotUrl",
        description="스냅샷 URL"
    )
    detected_at: datetime = Field(
        ..., 
        alias="detectedAt",
        description="탐지 일시"
    )
    bbox: BoundingBox = Field(
        ..., 
        description="바운딩 박스"
    )
    mask: Optional[str] = Field(
        None,
        description="세그멘테이션 마스크 (JSON Polygon String)"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


class DetectionDetail(BaseModel):
    """탐지 결과 상세 응답 스키마"""
    
    id: int = Field(..., description="탐지 ID")
    panel_id: int = Field(..., alias="panelId", description="패널 ID")
    panel_name: Optional[str] = Field(
        None, 
        alias="panelName",
        description="패널 이름"
    )
    defect_type: str = Field(..., alias="defectType", description="결함 유형")
    defect_subtype: Optional[str] = Field(
        None, 
        alias="defectSubtype",
        description="결함 세부 유형"
    )
    confidence: float = Field(..., description="신뢰도")
    bbox: BoundingBox = Field(..., description="바운딩 박스")
    mask: Optional[str] = Field(
        None,
        description="세그멘테이션 마스크 (JSON Polygon String)"
    )
    snapshot_url: Optional[str] = Field(
        None, 
        alias="snapshotUrl",
        description="스냅샷 URL"
    )
    frame_number: Optional[int] = Field(
        None, 
        alias="frameNumber",
        description="프레임 번호"
    )
    area_percentage: Optional[float] = Field(
        None, 
        alias="areaPercentage",
        description="결함 영역 비율 (%)"
    )
    detected_at: datetime = Field(
        ..., 
        alias="detectedAt",
        description="탐지 일시"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )

    @classmethod
    def from_orm_with_bbox(cls, detection) -> "DetectionDetail":
        """ORM 모델에서 변환 (바운딩 박스 포함)"""
        return cls(
            id=detection.id,
            panel_id=detection.panel_id,
            panel_name=getattr(detection.panel, "name", None) if detection.panel else None,
            defect_type=detection.defect_type,
            defect_subtype=detection.defect_subtype,
            confidence=detection.confidence,
            bbox=BoundingBox(
                x=detection.bbox_x,
                y=detection.bbox_y,
                width=detection.bbox_width,
                height=detection.bbox_height,
            ),
            snapshot_url=detection.snapshot_url,
            frame_number=detection.frame_number,
            area_percentage=detection.area_percentage,
            detected_at=detection.detected_at,
        )


# ─────────────────────────────────────────────────────────────────────────────
# 탐지 필터 스키마
# ─────────────────────────────────────────────────────────────────────────────

class DetectionFilter(BaseModel):
    """탐지 결과 필터 스키마 (쿼리 파라미터)"""
    
    panel_id: Optional[int] = Field(
        None, 
        alias="panelId",
        description="패널 ID 필터"
    )
    defect_type: Optional[DefectType] = Field(
        None, 
        alias="defectType",
        description="결함 유형 필터"
    )
    defect_subtype: Optional[DefectSubtype] = Field(
        None, 
        alias="defectSubtype",
        description="결함 세부 유형 필터"
    )
    min_confidence: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=1.0,
        alias="minConfidence",
        description="최소 신뢰도"
    )
    max_confidence: Optional[float] = Field(
        None, 
        ge=0.0, 
        le=1.0,
        alias="maxConfidence",
        description="최대 신뢰도"
    )
    start_date: Optional[date] = Field(
        None, 
        alias="startDate",
        description="시작 날짜"
    )
    end_date: Optional[date] = Field(
        None, 
        alias="endDate",
        description="종료 날짜"
    )

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 탐지 통계 스키마
# ─────────────────────────────────────────────────────────────────────────────

class DetectionStats(BaseModel):
    """탐지 통계 스키마"""
    
    total_count: int = Field(..., alias="totalCount", description="전체 탐지 건수")
    defect_count: int = Field(..., alias="defectCount", description="결함 탐지 건수")
    soiling_count: int = Field(..., alias="soilingCount", description="오염 탐지 건수")
    normal_count: int = Field(..., alias="normalCount", description="정상 건수")
    avg_confidence: Optional[float] = Field(
        None, 
        alias="avgConfidence",
        description="평균 신뢰도"
    )

    model_config = ConfigDict(populate_by_name=True)
