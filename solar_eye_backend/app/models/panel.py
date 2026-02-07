"""
Solar Eye Backend - Panel Model

태양광 패널/발전소 정보 모델
"""

from datetime import datetime
from enum import Enum as PyEnum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import (
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.daily_report import DailyReport
    from app.models.detection import Detection
    from app.models.user import User


class PanelStatus(str, PyEnum):
    """패널 상태 열거형"""
    ACTIVE = "active"        # 정상 작동
    INACTIVE = "inactive"    # 비활성화
    ERROR = "error"          # 오류 발생
    MAINTENANCE = "maintenance"  # 점검 중


class Panel(Base, TimestampMixin):
    """
    패널/발전소 모델
    
    사용자가 등록한 태양광 패널 또는 발전소 정보
    RTSP 스트림 URL 및 위치 정보 포함
    """

    __tablename__ = "panels"

    # Primary Key
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    # Foreign Key - User
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="소유자 사용자 ID",
    )

    # 기본 정보
    name: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
        comment="패널/발전소 이름",
    )

    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="설명",
    )

    location: Mapped[Optional[str]] = mapped_column(
        String(255),
        nullable=True,
        comment="위치 (주소)",
    )

    # RTSP 스트림
    rtsp_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="RTSP 스트림 URL",
    )

    # 상태
    status: Mapped[str] = mapped_column(
        String(20),
        default=PanelStatus.INACTIVE.value,
        nullable=False,
        index=True,
        comment="패널 상태 (active/inactive/error/maintenance)",
    )

    # 위치 좌표
    latitude: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="위도",
    )

    longitude: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="경도",
    )

    # 기상청 격자 좌표 (위경도 → 격자 변환)
    grid_nx: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="기상청 격자 X",
    )

    grid_ny: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="기상청 격자 Y",
    )

    # 패널 사양 (선택사항)
    capacity_kw: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="발전 용량 (kW)",
    )

    panel_count: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="패널 개수",
    )

    # 대표 이미지
    thumbnail_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="대표 이미지 URL",
    )

    # Relationships
    user: Mapped["User"] = relationship(
        "User",
        back_populates="panels",
    )

    detections: Mapped[list["Detection"]] = relationship(
        "Detection",
        back_populates="panel",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    daily_reports: Mapped[list["DailyReport"]] = relationship(
        "DailyReport",
        back_populates="panel",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<Panel(id={self.id}, name='{self.name}', status='{self.status}')>"
