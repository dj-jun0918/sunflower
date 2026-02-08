"""
Solar Eye Backend - Analysis Session Model

이미지/모니터링 분석 세션 정보 모델
"""

from datetime import datetime
from enum import Enum as PyEnum
from typing import TYPE_CHECKING, Optional
import uuid

from sqlalchemy import (
    DateTime,
    Enum,
    ForeignKey,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.panel import Panel
    from app.models.detection import Detection


class AnalysisStatus(str, PyEnum):
    """분석 상태 열거형"""
    PROCESSING = "processing"    # 처리 중
    COMPLETED = "completed"      # 완료
    FAILED = "failed"            # 실패


class MonitoringType(str, PyEnum):
    """모니터링 유형 열거형"""
    CCTV = "cctv"   # CCTV
    DRONE = "drone" # 드론


class AnalysisSession(Base):
    """
    분석 세션 모델
    
    한 번의 모니터링 분석 요청(이미지 업로드)에 대한 세션 정보
    """

    __tablename__ = "analysis_sessions"

    # Primary Key - UUID 사용
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    # Foreign Key - Panel
    panel_id: Mapped[int] = mapped_column(
        ForeignKey("panels.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="패널 ID",
    )

    # 상태
    status: Mapped[AnalysisStatus] = mapped_column(
        Enum(AnalysisStatus, name="analysis_status_enum", native_enum=False),
        nullable=False,
        default=AnalysisStatus.PROCESSING,
        index=True,
        comment="분석 상태 (processing/completed/failed)",
    )

    # 모니터링 유형
    type: Mapped[MonitoringType] = mapped_column(
        Enum(MonitoringType, name="monitoring_type_enum", native_enum=False),
        nullable=False,
        default=MonitoringType.CCTV,
        comment="모니터링 유형 (cctv/drone)",
    )

    # 원본 이미지 URL
    original_image_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="원본 이미지 URL",
    )

    # 생성 일시
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
        comment="분석 요청 일시",
    )

    # Relationships
    panel: Mapped["Panel"] = relationship(
        "Panel",
        backref="analysis_sessions",
    )

    detections: Mapped[list["Detection"]] = relationship(
        "Detection",
        back_populates="analysis_session",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<AnalysisSession(id={self.id}, status='{self.status}', type='{self.type}')>"
