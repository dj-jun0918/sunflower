"""
Solar Eye Backend - Panel Schemas

패널/발전소 관련 Pydantic 스키마 정의
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator


class PanelStatus(str, Enum):
    """패널 상태 열거형"""
    ACTIVE = "active"           # 정상 작동
    INACTIVE = "inactive"       # 비활성화
    ERROR = "error"             # 오류 발생
    MAINTENANCE = "maintenance" # 점검 중


# ─────────────────────────────────────────────────────────────────────────────
# 기본 패널 스키마
# ─────────────────────────────────────────────────────────────────────────────

class PanelBase(BaseModel):
    """패널 기본 스키마"""
    
    name: str = Field(
        ..., 
        min_length=1, 
        max_length=100,
        description="패널/발전소 이름"
    )
    description: Optional[str] = Field(
        None, 
        description="설명"
    )
    location: Optional[str] = Field(
        None, 
        max_length=255,
        description="위치 (주소)"
    )
    rtsp_url: Optional[str] = Field(
        None, 
        alias="rtspUrl",
        description="RTSP 스트림 URL"
    )
    latitude: Optional[float] = Field(
        None, 
        ge=-90, 
        le=90,
        description="위도"
    )
    longitude: Optional[float] = Field(
        None, 
        ge=-180, 
        le=180,
        description="경도"
    )
    capacity_kw: Optional[float] = Field(
        None, 
        ge=0,
        alias="capacityKw",
        description="발전 용량 (kW)"
    )
    panel_count: Optional[int] = Field(
        None, 
        ge=0,
        alias="panelCount",
        description="패널 개수"
    )

    model_config = ConfigDict(populate_by_name=True)


class PanelCreate(PanelBase):
    """패널 등록 요청 스키마"""
    
    @field_validator("name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        """이름 유효성 검사"""
        if not v or len(v.strip()) == 0:
            raise ValueError("패널 이름은 비어있을 수 없습니다")
        return v.strip()
    
    @field_validator("rtsp_url")
    @classmethod
    def validate_rtsp_url(cls, v: Optional[str]) -> Optional[str]:
        """RTSP URL 유효성 검사"""
        if v is not None:
            v = v.strip()
            if v and not v.startswith(("rtsp://", "rtsps://")):
                raise ValueError("RTSP URL은 rtsp:// 또는 rtsps://로 시작해야 합니다")
        return v if v else None


class PanelUpdate(BaseModel):
    """패널 수정 요청 스키마 (모든 필드 Optional)"""
    
    name: Optional[str] = Field(
        None, 
        min_length=1, 
        max_length=100,
        description="패널/발전소 이름"
    )
    description: Optional[str] = Field(
        None, 
        description="설명"
    )
    location: Optional[str] = Field(
        None, 
        max_length=255,
        description="위치 (주소)"
    )
    rtsp_url: Optional[str] = Field(
        None, 
        alias="rtspUrl",
        description="RTSP 스트림 URL"
    )
    status: Optional[PanelStatus] = Field(
        None, 
        description="패널 상태"
    )
    latitude: Optional[float] = Field(
        None, 
        ge=-90, 
        le=90,
        description="위도"
    )
    longitude: Optional[float] = Field(
        None, 
        ge=-180, 
        le=180,
        description="경도"
    )
    capacity_kw: Optional[float] = Field(
        None, 
        ge=0,
        alias="capacityKw",
        description="발전 용량 (kW)"
    )
    panel_count: Optional[int] = Field(
        None, 
        ge=0,
        alias="panelCount",
        description="패널 개수"
    )
    thumbnail_url: Optional[str] = Field(
        None,
        alias="thumbnailUrl",
        description="대표 이미지 URL"
    )

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 패널 응답 스키마
# ─────────────────────────────────────────────────────────────────────────────

class PanelResponse(BaseModel):
    """패널 정보 응답 스키마 (목록용)"""
    
    id: int = Field(..., description="패널 ID")
    name: str = Field(..., description="패널/발전소 이름")
    location: Optional[str] = Field(None, description="위치")
    status: str = Field(..., description="패널 상태")
    thumbnail_url: Optional[str] = Field(
        None, 
        alias="thumbnailUrl",
        description="대표 이미지 URL"
    )
    capacity_kw: Optional[float] = Field(
        None, 
        alias="capacityKw",
        description="발전 용량 (kW)"
    )
    panel_count: Optional[int] = Field(
        None, 
        alias="panelCount",
        description="패널 개수"
    )
    created_at: datetime = Field(
        ..., 
        alias="createdAt",
        description="등록일시"
    )
    updated_at: Optional[datetime] = Field(
        None, 
        alias="updatedAt",
        description="수정일시"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


class PanelDetail(BaseModel):
    """패널 상세 정보 응답 스키마"""
    
    id: int = Field(..., description="패널 ID")
    user_id: int = Field(..., alias="userId", description="소유자 ID")
    name: str = Field(..., description="패널/발전소 이름")
    description: Optional[str] = Field(None, description="설명")
    location: Optional[str] = Field(None, description="위치")
    rtsp_url: Optional[str] = Field(
        None, 
        alias="rtspUrl",
        description="RTSP 스트림 URL"
    )
    status: str = Field(..., description="패널 상태")
    latitude: Optional[float] = Field(None, description="위도")
    longitude: Optional[float] = Field(None, description="경도")
    grid_nx: Optional[int] = Field(
        None, 
        alias="gridNx",
        description="기상청 격자 X"
    )
    grid_ny: Optional[int] = Field(
        None, 
        alias="gridNy",
        description="기상청 격자 Y"
    )
    capacity_kw: Optional[float] = Field(
        None, 
        alias="capacityKw",
        description="발전 용량 (kW)"
    )
    panel_count: Optional[int] = Field(
        None, 
        alias="panelCount",
        description="패널 개수"
    )
    thumbnail_url: Optional[str] = Field(
        None, 
        alias="thumbnailUrl",
        description="대표 이미지 URL"
    )
    created_at: datetime = Field(
        ..., 
        alias="createdAt",
        description="등록일시"
    )
    updated_at: Optional[datetime] = Field(
        None, 
        alias="updatedAt",
        description="수정일시"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


# ─────────────────────────────────────────────────────────────────────────────
# 패널 상태 스키마
# ─────────────────────────────────────────────────────────────────────────────

class PanelStatusResponse(BaseModel):
    """패널 실시간 상태 응답 스키마"""
    
    panel_id: int = Field(..., alias="panelId", description="패널 ID")
    status: str = Field(..., description="패널 상태")
    is_streaming: bool = Field(
        ..., 
        alias="isStreaming",
        description="스트리밍 활성화 여부"
    )
    last_detection_at: Optional[datetime] = Field(
        None, 
        alias="lastDetectionAt",
        description="마지막 탐지 시간"
    )
    today_defects: int = Field(
        default=0, 
        alias="todayDefects",
        description="오늘 탐지된 결함 수"
    )
    today_soiling: int = Field(
        default=0, 
        alias="todaySoiling",
        description="오늘 탐지된 오염 수"
    )

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 패널 필터 스키마
# ─────────────────────────────────────────────────────────────────────────────

class PanelFilter(BaseModel):
    """패널 목록 필터 스키마"""
    
    status: Optional[PanelStatus] = Field(
        None, 
        description="상태 필터"
    )
    search: Optional[str] = Field(
        None, 
        description="검색어 (이름, 위치)"
    )

    model_config = ConfigDict(populate_by_name=True)
