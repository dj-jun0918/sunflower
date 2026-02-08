"""
Solar Eye Backend - API v1 Package

API 버전 1 라우터 모음
"""

from fastapi import APIRouter

from app.api.v1.auth import router as auth_router
from app.api.v1.panels import router as panels_router
from app.api.v1.detections import router as detections_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.reports import router as reports_router
from app.api.v1.weather import router as weather_router
from app.api.v1.analysis import router as analysis_router
from app.api.v1.stream import router as stream_router
from app.api.v1.endpoints.monitoring import router as monitoring_router
from app.api.v1.endpoints.services import router as services_router

# v1 API 라우터
api_router = APIRouter()

# 라우터 등록
api_router.include_router(auth_router)
api_router.include_router(panels_router)
api_router.include_router(detections_router)
api_router.include_router(alerts_router)
api_router.include_router(reports_router)
api_router.include_router(weather_router)
api_router.include_router(analysis_router)
api_router.include_router(stream_router)
api_router.include_router(monitoring_router, prefix="/monitoring", tags=["Monitoring"])
api_router.include_router(services_router, prefix="/services", tags=["Services"])

__all__ = ["api_router"]

