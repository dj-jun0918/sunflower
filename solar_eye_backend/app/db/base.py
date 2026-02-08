"""
Solar Eye Backend - SQLAlchemy Base Model

모든 SQLAlchemy 모델의 기본 클래스 정의
"""

from datetime import datetime
from typing import Any

from sqlalchemy import DateTime, func
from sqlalchemy.orm import DeclarativeBase, Mapped, declared_attr, mapped_column


class Base(DeclarativeBase):
    """
    SQLAlchemy 선언적 베이스 클래스
    
    모든 모델은 이 클래스를 상속받아야 함
    """

    id: Any

    @declared_attr.directive
    def __tablename__(cls) -> str:
        """테이블명 자동 생성 (클래스명을 snake_case로 변환)"""
        # CamelCase -> snake_case 변환
        name = cls.__name__
        return ''.join(
            ['_' + c.lower() if c.isupper() else c for c in name]
        ).lstrip('_')


class TimestampMixin:
    """
    Timestamp Mixin
    
    created_at, updated_at 필드를 자동으로 추가
    """

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="생성 일시",
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
        comment="수정 일시",
    )
