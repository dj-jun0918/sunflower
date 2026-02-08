"""
Solar Eye Backend - Common Schemas

공통으로 사용되는 Pydantic 스키마 정의
"""

from datetime import datetime
from typing import Any, Generic, Optional, TypeVar

from pydantic import BaseModel, ConfigDict, Field

# Generic type for response data
T = TypeVar("T")


class BaseSchema(BaseModel):
    """기본 스키마 - 모든 스키마의 베이스"""
    
    model_config = ConfigDict(
        from_attributes=True,  # ORM 모델 → Pydantic 변환 허용
        populate_by_name=True,  # alias로도 필드 접근 가능
        str_strip_whitespace=True,  # 문자열 앞뒤 공백 제거
    )


# ─────────────────────────────────────────────────────────────────────────────
# 성공/에러 응답
# ─────────────────────────────────────────────────────────────────────────────

class SuccessResponse(BaseModel, Generic[T]):
    """성공 응답 - 제네릭 데이터 래퍼"""
    
    success: bool = Field(default=True, description="요청 성공 여부")
    message: str = Field(default="Success", description="응답 메시지")
    data: Optional[T] = Field(default=None, description="응답 데이터")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="응답 시간 (UTC)"
    )

    model_config = ConfigDict(from_attributes=True)


class ErrorDetail(BaseModel):
    """에러 상세 정보"""
    
    field: Optional[str] = Field(default=None, description="에러 발생 필드")
    message: str = Field(..., description="에러 메시지")
    code: Optional[str] = Field(default=None, description="에러 코드")


class ErrorResponse(BaseModel):
    """에러 응답"""
    
    success: bool = Field(default=False, description="요청 성공 여부")
    message: str = Field(..., description="에러 메시지")
    error_code: Optional[str] = Field(default=None, description="에러 코드")
    details: Optional[list[ErrorDetail]] = Field(
        default=None,
        description="상세 에러 정보"
    )
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="응답 시간 (UTC)"
    )

    model_config = ConfigDict(from_attributes=True)


# ─────────────────────────────────────────────────────────────────────────────
# 페이지네이션
# ─────────────────────────────────────────────────────────────────────────────

class PaginationParams(BaseModel):
    """페이지네이션 요청 파라미터"""
    
    page: int = Field(
        default=1,
        ge=1,
        description="페이지 번호 (1부터 시작)"
    )
    page_size: int = Field(
        default=20,
        ge=1,
        le=100,
        alias="pageSize",
        description="페이지당 항목 수 (최대 100)"
    )
    
    @property
    def offset(self) -> int:
        """DB 쿼리용 offset 계산"""
        return (self.page - 1) * self.page_size
    
    @property
    def limit(self) -> int:
        """DB 쿼리용 limit"""
        return self.page_size


class PaginationMeta(BaseModel):
    """페이지네이션 메타 정보"""
    
    current_page: int = Field(..., alias="currentPage", description="현재 페이지")
    page_size: int = Field(..., alias="pageSize", description="페이지당 항목 수")
    total_items: int = Field(..., alias="totalItems", description="전체 항목 수")
    total_pages: int = Field(..., alias="totalPages", description="전체 페이지 수")
    has_next: bool = Field(..., alias="hasNext", description="다음 페이지 존재 여부")
    has_previous: bool = Field(..., alias="hasPrevious", description="이전 페이지 존재 여부")

    model_config = ConfigDict(populate_by_name=True)

    @classmethod
    def create(
        cls,
        page: int,
        page_size: int,
        total_items: int
    ) -> "PaginationMeta":
        """페이지네이션 메타 정보 생성"""
        total_pages = (total_items + page_size - 1) // page_size if page_size > 0 else 0
        return cls(
            current_page=page,
            page_size=page_size,
            total_items=total_items,
            total_pages=total_pages,
            has_next=page < total_pages,
            has_previous=page > 1,
        )


class PaginatedResponse(BaseModel, Generic[T]):
    """페이지네이션된 응답"""
    
    success: bool = Field(default=True, description="요청 성공 여부")
    data: list[T] = Field(default_factory=list, description="데이터 목록")
    pagination: PaginationMeta = Field(..., description="페이지네이션 정보")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="응답 시간 (UTC)"
    )

    model_config = ConfigDict(from_attributes=True)


# ─────────────────────────────────────────────────────────────────────────────
# 공통 유틸리티 스키마
# ─────────────────────────────────────────────────────────────────────────────

class HealthCheckResponse(BaseModel):
    """헬스체크 응답"""
    
    status: str = Field(default="ok", description="서비스 상태")
    version: Optional[str] = Field(default=None, description="API 버전")
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="응답 시간 (UTC)"
    )


class MessageResponse(BaseModel):
    """단순 메시지 응답"""
    
    success: bool = Field(default=True, description="요청 성공 여부")
    message: str = Field(..., description="메시지")


class IdResponse(BaseModel):
    """ID만 반환하는 응답 (생성/삭제 등)"""
    
    id: int = Field(..., description="리소스 ID")
    message: str = Field(default="Success", description="메시지")
