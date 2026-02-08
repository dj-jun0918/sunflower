"""
Solar Eye Backend - Exception Handlers

FastAPI 전역 에러 핸들러
"""

import logging
from typing import Any, Optional

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from sqlalchemy.exc import SQLAlchemyError

logger = logging.getLogger(__name__)


class APIException(Exception):
    """API 예외 기본 클래스"""
    
    def __init__(
        self,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail: str = "Internal server error",
        error_code: str = "INTERNAL_ERROR",
    ):
        self.status_code = status_code
        self.detail = detail
        self.error_code = error_code
        super().__init__(self.detail)


class NotFoundError(APIException):
    """리소스를 찾을 수 없음"""
    
    def __init__(self, detail: str = "Resource not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=detail,
            error_code="NOT_FOUND",
        )


class UnauthorizedError(APIException):
    """인증 실패"""
    
    def __init__(self, detail: str = "Authentication required"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
            error_code="UNAUTHORIZED",
        )


class ForbiddenError(APIException):
    """권한 없음"""
    
    def __init__(self, detail: str = "Permission denied"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=detail,
            error_code="FORBIDDEN",
        )


class BadRequestError(APIException):
    """잘못된 요청"""
    
    def __init__(self, detail: str = "Bad request"):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=detail,
            error_code="BAD_REQUEST",
        )


class ConflictError(APIException):
    """리소스 충돌"""
    
    def __init__(self, detail: str = "Resource conflict"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            detail=detail,
            error_code="CONFLICT",
        )


def create_error_response(
    status_code: int,
    detail: str,
    error_code: str = "ERROR",
    errors: list[dict[str, Any]] | None = None,
) -> JSONResponse:
    """에러 응답 생성 (CORS 헤더 포함)"""
    content = {
        "success": False,
        "error": {
            "code": error_code,
            "message": detail,
        },
    }
    if errors:
        content["error"]["details"] = errors
    
    # CORS 헤더를 에러 응답에도 추가 (브라우저에서 에러 메시지를 읽을 수 있도록)
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "*",
        "Access-Control-Allow-Headers": "*",
    }
        
    return JSONResponse(status_code=status_code, content=content, headers=headers)


def register_exception_handlers(app: FastAPI) -> None:
    """FastAPI 앱에 에러 핸들러 등록"""
    
    @app.exception_handler(APIException)
    async def api_exception_handler(request: Request, exc: APIException) -> JSONResponse:
        """API 예외 핸들러"""
        logger.warning(f"API Exception: {exc.error_code} - {exc.detail}")
        return create_error_response(
            status_code=exc.status_code,
            detail=exc.detail,
            error_code=exc.error_code,
        )
    
    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(
        request: Request, exc: RequestValidationError
    ) -> JSONResponse:
        """요청 검증 에러 핸들러"""
        errors = []
        for error in exc.errors():
            errors.append({
                "field": ".".join(str(loc) for loc in error["loc"]),
                "message": error["msg"],
                "type": error["type"],
            })
        
        logger.warning(f"Validation Error: {errors}")
        return create_error_response(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Validation error",
            error_code="VALIDATION_ERROR",
            errors=errors,
        )
    
    @app.exception_handler(ValidationError)
    async def pydantic_validation_handler(
        request: Request, exc: ValidationError
    ) -> JSONResponse:
        """Pydantic 검증 에러 핸들러"""
        errors = []
        for error in exc.errors():
            errors.append({
                "field": ".".join(str(loc) for loc in error["loc"]),
                "message": error["msg"],
                "type": error["type"],
            })
        
        logger.warning(f"Pydantic Validation Error: {errors}")
        return create_error_response(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Validation error",
            error_code="VALIDATION_ERROR",
            errors=errors,
        )
    
    @app.exception_handler(SQLAlchemyError)
    async def sqlalchemy_exception_handler(
        request: Request, exc: SQLAlchemyError
    ) -> JSONResponse:
        """SQLAlchemy 에러 핸들러"""
        logger.error(f"Database Error: {exc}")
        return create_error_response(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database error occurred",
            error_code="DATABASE_ERROR",
        )
    
    @app.exception_handler(Exception)
    async def general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        """일반 예외 핸들러"""
        logger.exception(f"Unhandled Exception: {exc}")
        return create_error_response(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred",
            error_code="INTERNAL_ERROR",
        )
