"""
Solar Eye Backend - Alert Model

푸시 알림 정보 모델
"""

from datetime import datetime
from enum import Enum as PyEnum
from typing import TYPE_CHECKING, Optional

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.detection import Detection
    from app.models.user import User


class AlertType(str, PyEnum):
    """알림 유형 열거형"""
    DEFECT = "defect"        # 결함 탐지 알림
    SOILING = "soiling"      # 오염 탐지 알림
    REPORT = "report"        # 리포트 알림
    SYSTEM = "system"        # 시스템 알림
    WEATHER = "weather"      # 날씨 관련 알림


class Alert(Base):
    """
    알림 모델
    
    사용자에게 전송된 푸시 알림 정보
    탐지 결과와 연결되어 알림 이력 관리
    """

    __tablename__ = "alerts"

    # Primary Key
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    # Foreign Keys
    detection_id: Mapped[Optional[int]] = mapped_column(
        ForeignKey("detections.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
        comment="연결된 탐지 결과 ID",
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="수신 사용자 ID",
    )

    # 알림 정보
    alert_type: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        index=True,
        comment="알림 유형",
    )

    title: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
        comment="알림 제목",
    )

    message: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        comment="알림 내용",
    )

    # 이미지 (탐지 스냅샷 등)
    image_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="알림 이미지 URL",
    )

    # 딥링크 (앱 내 특정 화면으로 이동)
    deep_link: Mapped[Optional[str]] = mapped_column(
        String(500),
        nullable=True,
        comment="딥링크 URL",
    )

    # 읽음 상태
    is_read: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
        index=True,
        comment="읽음 여부",
    )

    # 발송/읽음 시간
    sent_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
        comment="발송 일시",
    )

    read_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
        comment="읽음 일시",
    )

    # Relationships
    detection: Mapped[Optional["Detection"]] = relationship(
        "Detection",
        back_populates="alerts",
    )

    user: Mapped["User"] = relationship(
        "User",
        back_populates="alerts",
    )

    def __repr__(self) -> str:
        return f"<Alert(id={self.id}, type='{self.alert_type}', is_read={self.is_read})>"

    def mark_as_read(self) -> None:
        """알림을 읽음으로 표시"""
        if not self.is_read:
            self.is_read = True
            self.read_at = datetime.utcnow()
