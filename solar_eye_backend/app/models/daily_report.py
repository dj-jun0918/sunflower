"""
Solar Eye Backend - Daily Report Model

일간 분석 리포트 모델
"""

from datetime import date, datetime
from typing import TYPE_CHECKING, Any, Optional

from sqlalchemy import Date, DateTime, Float, ForeignKey, Integer, Text, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.models.panel import Panel


class DailyReport(Base):
    """
    일간 리포트 모델
    
    패널별 일일 분석 결과 저장
    결함/오염 통계, 경제성 분석 포함
    """

    __tablename__ = "daily_reports"

    # Primary Key
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)

    # Foreign Key - Panel
    panel_id: Mapped[int] = mapped_column(
        ForeignKey("panels.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="패널 ID",
    )

    # 리포트 날짜
    report_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
        index=True,
        comment="리포트 날짜",
    )

    # 탐지 통계
    total_detections: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="총 탐지 건수",
    )

    total_defects: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="결함 탐지 건수",
    )

    total_soiling: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
        comment="오염 탐지 건수",
    )

    # 오염 영역 비율 (%)
    avg_soiling_area: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="평균 오염 영역 비율 (%)",
    )

    max_soiling_area: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="최대 오염 영역 비율 (%)",
    )

    # 경제성 분석
    estimated_loss_kwh: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="추정 발전 손실량 (kWh)",
    )

    estimated_loss_krw: Mapped[Optional[float]] = mapped_column(
        Float,
        nullable=True,
        comment="추정 손실 금액 (원)",
    )

    cleaning_recommended: Mapped[bool] = mapped_column(
        default=False,
        nullable=False,
        comment="청소 권고 여부",
    )

    # 날씨 정보 (당일)
    weather_summary: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="날씨 요약",
    )

    had_rain: Mapped[bool] = mapped_column(
        default=False,
        nullable=False,
        comment="강우 발생 여부",
    )

    # 상세 요약 (JSON)
    summary: Mapped[Optional[dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="상세 요약 데이터 (JSON)",
    )

    # ─────────────────────────────────────────────────────────────────────────
    # AI 브리핑 관련 필드
    # ─────────────────────────────────────────────────────────────────────────
    
    # AI 솔루션 타입: 'good', 'caution', 'danger'
    ai_solution_type: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="AI 솔루션 타입 (good/caution/danger)",
    )

    # AI 한줄 요약
    ai_solution_title: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="AI 솔루션 한줄 요약",
    )

    # AI 상세 솔루션
    ai_solution_content: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
        comment="AI 솔루션 상세 설명",
    )

    # AI 액션 아이템 (JSON 배열)
    ai_action_items: Mapped[Optional[list[str]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="AI 추천 액션 아이템 목록",
    )

    # 특이사항 목록 (JSON 배열)
    anomalies: Mapped[Optional[list[str]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="오늘 특이사항 목록",
    )

    # 내일 날씨 정보 (JSON)
    weather_forecast: Mapped[Optional[dict[str, Any]]] = mapped_column(
        JSONB,
        nullable=True,
        comment="내일 날씨 예보 정보",
    )

    # AI 생성 시각
    ai_generated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
        comment="AI 솔루션 생성 시각",
    )

    # 생성 일시
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="생성 일시",
    )

    # Relationships
    panel: Mapped["Panel"] = relationship(
        "Panel",
        back_populates="daily_reports",
    )

    def __repr__(self) -> str:
        return f"<DailyReport(id={self.id}, panel_id={self.panel_id}, date={self.report_date})>"

    class Config:
        """Unique constraint: panel_id + report_date"""
        # SQLAlchemy에서는 __table_args__로 처리
        pass

    __table_args__ = (
        # 패널별 날짜당 하나의 리포트만 허용
        {"comment": "일간 분석 리포트"},
    )
