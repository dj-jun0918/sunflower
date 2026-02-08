"""
Solar Eye Backend - User Model

사용자 정보 저장 모델
"""

from datetime import datetime
from typing import TYPE_CHECKING, Optional

from sqlalchemy import Boolean, DateTime, Enum, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin

if TYPE_CHECKING:
    from app.models.alert import Alert
    from app.models.panel import Panel


class AuthProvider(str, Enum):
    """인증 제공자 열거형"""
    GOOGLE = "google"
    APPLE = "apple"


class User(Base, TimestampMixin):
    """
    사용자 모델
    
    Firebase Authentication을 통해 인증된 사용자 정보 저장
    """

    __tablename__ = "users"

    # Primary Key
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    # Firebase UID (고유 식별자)
    firebase_uid: Mapped[str] = mapped_column(
        String(128),
        unique=True,
        nullable=False,
        index=True,
        comment="Firebase 사용자 UID",
    )

    # 기본 정보
    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        nullable=False,
        index=True,
        comment="이메일 주소",
    )

    display_name: Mapped[Optional[str]] = mapped_column(
        String(100),
        nullable=True,
        comment="표시 이름",
    )

    photo_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="프로필 이미지 URL",
    )

    # 인증 제공자
    provider: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
        default="google",
        comment="인증 제공자 (google/apple/kakao)",
    )

    # 알림 설정
    notification_enabled: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        comment="푸시 알림 활성화 여부",
    )

    fcm_token: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="FCM 토큰",
    )

    # 로그인 기록
    last_login_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
        comment="마지막 로그인 일시",
    )

    # 계정 상태
    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
        comment="계정 활성화 상태",
    )

    # Relationships
    panels: Mapped[list["Panel"]] = relationship(
        "Panel",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    alerts: Mapped[list["Alert"]] = relationship(
        "Alert",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    def __repr__(self) -> str:
        return f"<User(id={self.id}, email='{self.email}')>"
