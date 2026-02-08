"""
Solar Eye Backend - Schemas Package

Pydantic 스키마 모음
"""

# Common
from app.schemas.common import (
    BaseSchema,
    ErrorDetail,
    ErrorResponse,
    HealthCheckResponse,
    IdResponse,
    MessageResponse,
    PaginatedResponse,
    PaginationMeta,
    PaginationParams,
    SuccessResponse,
)

# User
from app.schemas.user import (
    AuthProvider,
    FCMTokenRequest,
    FCMTokenResponse,
    FirebaseUserInfo,
    LoginRequest,
    LoginResponse,
    UserCreate,
    UserResponse,
    UserUpdate,
)

# Panel
from app.schemas.panel import (
    PanelCreate,
    PanelDetail,
    PanelFilter,
    PanelResponse,
    PanelStatus,
    PanelStatusResponse,
    PanelUpdate,
)

# Detection
from app.schemas.detection import (
    BoundingBox,
    DefectSubtype,
    DefectType,
    DetectionCreate,
    DetectionDetail,
    DetectionFilter,
    DetectionResponse,
    DetectionStats,
)

# Alert
from app.schemas.alert import (
    AlertCreate,
    AlertDetail,
    AlertFilter,
    AlertList,
    AlertListMeta,
    AlertResponse,
    AlertType,
    MarkReadResponse,
    UnreadCountResponse,
)

# Report
from app.schemas.report import (
    DailyReportResponse,
    DailyTrend,
    EconomicReportResponse,
    ReportFilter,
    WeeklyReportResponse,
)

# Weather
from app.schemas.weather import (
    CurrentWeatherResponse,
    ForecastItem,
    ForecastResponse,
    WeatherStatus,
    WeatherStatusResponse,
)

__all__ = [
    # Common
    "BaseSchema",
    "SuccessResponse",
    "ErrorResponse",
    "ErrorDetail",
    "PaginationParams",
    "PaginationMeta",
    "PaginatedResponse",
    "HealthCheckResponse",
    "MessageResponse",
    "IdResponse",
    # User
    "AuthProvider",
    "UserCreate",
    "UserUpdate",
    "UserResponse",
    "LoginRequest",
    "LoginResponse",
    "FCMTokenRequest",
    "FCMTokenResponse",
    "FirebaseUserInfo",
    # Panel
    "PanelStatus",
    "PanelCreate",
    "PanelUpdate",
    "PanelResponse",
    "PanelDetail",
    "PanelStatusResponse",
    "PanelFilter",
    # Detection
    "DefectType",
    "DefectSubtype",
    "BoundingBox",
    "DetectionCreate",
    "DetectionResponse",
    "DetectionDetail",
    "DetectionFilter",
    "DetectionStats",
    # Alert
    "AlertType",
    "AlertResponse",
    "AlertDetail",
    "AlertList",
    "AlertListMeta",
    "AlertFilter",
    "AlertCreate",
    "MarkReadResponse",
    "UnreadCountResponse",
    # Report
    "DailyReportResponse",
    "WeeklyReportResponse",
    "DailyTrend",
    "EconomicReportResponse",
    "ReportFilter",
    # Weather
    "WeatherStatus",
    "CurrentWeatherResponse",
    "ForecastItem",
    "ForecastResponse",
    "WeatherStatusResponse",
]
