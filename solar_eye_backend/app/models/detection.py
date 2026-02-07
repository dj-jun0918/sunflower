"""
Solar Eye Backend - Detection Model

AI 탐지 결과 저장 모델
"""

from datetime import datetime
from enum import Enum as PyEnum
from typing import TYPE_CHECKING, Optional
import uuid

from sqlalchemy import (
    DateTime,
    Enum,
    Float,
    ForeignKey,
    Integer,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.alert import Alert
    from app.models.panel import Panel
    from app.models.analysis import AnalysisSession


class DefectType(str, PyEnum):
    """결함 유형 열거형"""
    DEFECT = "defect"        # 물리적 결함 (크랙, 파손 등)
    SOILING = "soiling"      # 오염 (먼지, 조류 배설물 등)
    NORMAL = "normal"        # 정상


class DefectSubtype(str, PyEnum):
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


class Detection(Base):
    """
    탐지 결과 모델
    
    AI 파이프라인을 통해 감지된 결함/오염 정보
    바운딩 박스, 신뢰도, 스냅샷 이미지 포함
    """

    __tablename__ = "detections"

    # Primary Key
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    # Foreign Key - Panel
    panel_id: Mapped[int] = mapped_column(
        ForeignKey("panels.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="패널 ID",
    )

    # Foreign Key - AnalysisSession (Optional initially for backward compatibility)
    analysis_session_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("analysis_sessions.id", ondelete="CASCADE"),
        nullable=True,
        index=True,
        comment="분석 세션 ID",
    )

    # 결함 유형 (Enum 타입으로 변경)
    defect_type: Mapped[DefectType] = mapped_column(
        Enum(DefectType, name="defect_type_enum", native_enum=False),
        nullable=False,
        index=True,
        comment="결함 유형 (defect/soiling/normal)",
    )

    # 결함 세부 유형 (Enum 타입으로 변경)
    defect_subtype: Mapped[Optional[DefectSubtype]] = mapped_column(
        Enum(DefectSubtype, name="defect_subtype_enum", native_enum=False),
        nullable=True,
        comment="결함 세부 유형",
    )

    # 신뢰도 (0.0 ~ 1.0)
    confidence: Mapped[float] = mapped_column(
        Float,
        nullable=False,
        comment="탐지 신뢰도 (0.0 ~ 1.0)",
    )

    # 바운딩 박스 좌표 (픽셀 단위)
    bbox_x: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="바운딩 박스 X 좌표",
    )

    bbox_y: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="바운딩 박스 Y 좌표",
    )

    bbox_width: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="바운딩 박스 너비",
    )

    bbox_height: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
        comment="바운딩 박스 높이",
    )

    # 스냅샷 이미지
    snapshot_url: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="스냅샷 이미지 URL",
    )

    # 추가 정보
    frame_number: Mapped[Optional[int]] = mapped_column(
        Integer,
        nullable=True,
        comment="프레임 번호",
    )

    area_percentage: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="결함 영역 비율 (%)",
    )
    
    # 세그멘테이션 마스크 (JSON String: List[List[int]])
    mask: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="세그멘테이션 마스크 Polygon (JSON)",
    )

    # 탐지 일시
    detected_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
        comment="탐지 일시",
    )

    # Relationships
    panel: Mapped["Panel"] = relationship(
        "Panel",
        back_populates="detections",
    )

    analysis_session: Mapped[Optional["AnalysisSession"]] = relationship(
        "AnalysisSession",
        back_populates="detections",
    )

    alerts: Mapped[list["Alert"]] = relationship(
        "Alert",
        back_populates="detection",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    @property
    def bbox(self):
        """Pydantic 호환용 바운딩 박스 속성"""
        return {
            "x": self.bbox_x,
            "y": self.bbox_y,
            "width": self.bbox_width,
            "height": self.bbox_height
        }

    def __repr__(self) -> str:
        return f"<Detection(id={self.id}, type='{self.defect_type}', confidence={self.confidence:.2f})>"
