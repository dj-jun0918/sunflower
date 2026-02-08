"""
Solar Eye Backend - Alert Schemas

알림 관련 Pydantic 스키마 정의
"""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field


class AlertType(str, Enum):
    """알림 유형 열거형"""
    DEFECT = "defect"        # 결함 탐지 알림
    SOILING = "soiling"      # 오염 탐지 알림
    REPORT = "report"        # 리포트 알림
    SYSTEM = "system"        # 시스템 알림
    WEATHER = "weather"      # 날씨 관련 알림


# ─────────────────────────────────────────────────────────────────────────────
# 알림 응답 스키마
# ─────────────────────────────────────────────────────────────────────────────

class AlertResponse(BaseModel):
    """알림 응답 스키마 (목록용)"""
    
    id: int = Field(..., description="알림 ID")
    alert_type: str = Field(..., alias="alertType", description="알림 유형")
    title: str = Field(..., description="알림 제목")
    message: str = Field(..., description="알림 내용")
    image_url: Optional[str] = Field(
        None, 
        alias="imageUrl",
        description="알림 이미지 URL"
    )
    deep_link: Optional[str] = Field(
        None, 
        alias="deepLink",
        description="딥링크 URL"
    )
    is_read: bool = Field(..., alias="isRead", description="읽음 여부")
    sent_at: datetime = Field(..., alias="sentAt", description="발송 일시")
    read_at: Optional[datetime] = Field(
        None, 
        alias="readAt",
        description="읽음 일시"
    )
    detection_id: Optional[int] = Field(
        None, 
        alias="detectionId",
        description="연결된 탐지 결과 ID"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


class AlertDetail(BaseModel):
    """알림 상세 응답 스키마"""
    
    id: int = Field(..., description="알림 ID")
    user_id: int = Field(..., alias="userId", description="수신자 ID")
    alert_type: str = Field(..., alias="alertType", description="알림 유형")
    title: str = Field(..., description="알림 제목")
    message: str = Field(..., description="알림 내용")
    image_url: Optional[str] = Field(
        None, 
        alias="imageUrl",
        description="알림 이미지 URL"
    )
    deep_link: Optional[str] = Field(
        None, 
        alias="deepLink",
        description="딥링크 URL"
    )
    is_read: bool = Field(..., alias="isRead", description="읽음 여부")
    sent_at: datetime = Field(..., alias="sentAt", description="발송 일시")
    read_at: Optional[datetime] = Field(
        None, 
        alias="readAt",
        description="읽음 일시"
    )
    detection_id: Optional[int] = Field(
        None, 
        alias="detectionId",
        description="연결된 탐지 결과 ID"
    )
    # 연결된 탐지 정보 (있는 경우)
    panel_name: Optional[str] = Field(
        None, 
        alias="panelName",
        description="패널 이름"
    )

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True,
    )


# ─────────────────────────────────────────────────────────────────────────────
# 알림 목록 응답 스키마
# ─────────────────────────────────────────────────────────────────────────────

class AlertListMeta(BaseModel):
    """알림 목록 메타 정보"""
    
    total_count: int = Field(..., alias="totalCount", description="전체 알림 수")
    unread_count: int = Field(..., alias="unreadCount", description="읽지 않은 알림 수")

    model_config = ConfigDict(populate_by_name=True)


class AlertList(BaseModel):
    """알림 목록 응답 스키마"""
    
    alerts: list[AlertResponse] = Field(default_factory=list, description="알림 목록")
    meta: AlertListMeta = Field(..., description="메타 정보")

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 알림 필터 스키마
# ─────────────────────────────────────────────────────────────────────────────

class AlertFilter(BaseModel):
    """알림 필터 스키마 (쿼리 파라미터)"""
    
    alert_type: Optional[AlertType] = Field(
        None, 
        alias="alertType",
        description="알림 유형 필터"
    )
    is_read: Optional[bool] = Field(
        None, 
        alias="isRead",
        description="읽음 여부 필터"
    )
    panel_id: Optional[int] = Field(
        None, 
        alias="panelId",
        description="패널 ID 필터"
    )

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 알림 생성 스키마 (내부 사용)
# ─────────────────────────────────────────────────────────────────────────────

class AlertCreate(BaseModel):
    """알림 생성 스키마 (내부 사용)"""
    
    user_id: int = Field(..., alias="userId", description="수신자 ID")
    alert_type: AlertType = Field(..., alias="alertType", description="알림 유형")
    title: str = Field(..., max_length=200, description="알림 제목")
    message: str = Field(..., description="알림 내용")
    image_url: Optional[str] = Field(
        None, 
        alias="imageUrl",
        description="알림 이미지 URL"
    )
    deep_link: Optional[str] = Field(
        None, 
        max_length=500,
        alias="deepLink",
        description="딥링크 URL"
    )
    detection_id: Optional[int] = Field(
        None, 
        alias="detectionId",
        description="연결된 탐지 결과 ID"
    )

    model_config = ConfigDict(populate_by_name=True)


# ─────────────────────────────────────────────────────────────────────────────
# 알림 읽음 처리 스키마
# ─────────────────────────────────────────────────────────────────────────────

class MarkReadResponse(BaseModel):
    """알림 읽음 처리 응답"""
    
    success: bool = Field(default=True, description="처리 성공 여부")
    message: str = Field(default="알림을 읽음 처리했습니다", description="응답 메시지")
    read_count: int = Field(
        default=1, 
        alias="readCount",
        description="읽음 처리된 알림 수"
    )

    model_config = ConfigDict(populate_by_name=True)


class UnreadCountResponse(BaseModel):
    """읽지 않은 알림 개수 응답"""
    
    count: int = Field(..., description="읽지 않은 알림 개수")

    model_config = ConfigDict(populate_by_name=True)
