"""
Solar Eye Backend - FastAPI Main Application

FastAPI 앱 인스턴스 및 기본 설정
"""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.core.exceptions import register_exception_handlers
from app.core.firebase import close_firebase, init_firebase
from app.core.redis import close_redis, init_redis

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    애플리케이션 라이프사이클 이벤트 관리
    
    startup: 앱 시작 시 실행 (DB 연결, Redis 연결 등)
    shutdown: 앱 종료 시 실행 (연결 정리)
    """
    # =========================================================================
    # Startup
    # =========================================================================
    logger.info(f"🚀 Starting {settings.app_name} in {settings.app_env} mode...")
    
    # Firebase 초기화
    firebase_app = init_firebase()
    if firebase_app:
        logger.info("✅ Firebase initialized")
    else:
        logger.warning("⚠️ Firebase not configured")
    
    # Redis 초기화
    redis_client = await init_redis()
    if redis_client:
        logger.info("✅ Redis connected")
    else:
        logger.warning("⚠️ Redis not connected")
    
    # AI 파이프라인 초기화
    try:
        from app.ai import get_pipeline
        pipeline = get_pipeline()
        logger.info("✅ AI Pipeline loaded (YOLO + EfficientNet)")
    except FileNotFoundError as e:
        logger.error(f"❌ AI 모델 파일을 찾을 수 없습니다: {e}")
        logger.warning("⚠️ AI 분석 기능이 비활성화됩니다")
    except Exception as e:
        logger.error(f"❌ AI 파이프라인 로드 실패: {e}")
        logger.warning("⚠️ AI 분석 기능이 비활성화됩니다")
    
    # 백그라운드 스케줄러 시작
    try:
        from app.core.background_tasks import start_scheduler
        await start_scheduler()
        logger.info("✅ Background scheduler started")
    except Exception as e:
        logger.error(f"❌ 백그라운드 스케줄러 시작 실패: {e}")
        logger.warning("⚠️ 스케줄러 기능이 비활성화됩니다")
    
    logger.info(f"✅ {settings.app_name} started successfully!")
    
    yield
    
    # =========================================================================
    # Shutdown
    # =========================================================================
    logger.info(f"🛑 Shutting down {settings.app_name}...")
    
    # 백그라운드 스케줄러 중지
    try:
        from app.core.background_tasks import stop_scheduler
        await stop_scheduler()
        logger.info("✅ Background scheduler stopped")
    except Exception as e:
        logger.warning(f"⚠️ 스케줄러 중지 중 오류: {e}")
    
    # 스트림 매니저 종료
    try:
        from app.ai.stream_processor import get_stream_manager
        manager = get_stream_manager()
        await manager.stop_all()
        logger.info("✅ Stream manager stopped")
    except Exception as e:
        logger.warning(f"⚠️ 스트림 매니저 중지 중 오류: {e}")
    
    # Redis 종료
    await close_redis()
    logger.info("✅ Redis disconnected")
    
    # Firebase 종료
    close_firebase()
    logger.info("✅ Firebase closed")
    
    logger.info(f"✅ {settings.app_name} shutdown complete!")

def create_application() -> FastAPI:
    """FastAPI 애플리케이션 팩토리"""
    
    app = FastAPI(
        title=settings.app_name,
        description="AI-powered Solar Panel Defect Detection Backend API",
        version="0.1.0",
        docs_url="/docs" if settings.debug else None,
        redoc_url="/redoc" if settings.debug else None,
        openapi_url="/openapi.json" if settings.debug else None,
        lifespan=lifespan,
    )

    # CORS 미들웨어 설정 (Cloud Run 호환성을 위해 모든 오리진 허용)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Hardcoded for Cloud Run compatibility
        allow_credentials=False,  # Must be False when allow_origins is ["*"]
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 에러 핸들러 등록
    register_exception_handlers(app)

    # =========================================================================
    # API 라우터 등록
    # =========================================================================
    from app.api.v1 import api_router
    
    app.include_router(api_router, prefix="/api/v1")

    return app


# FastAPI 앱 인스턴스
app = create_application()


@app.get("/", tags=["Root"])
async def root():
    """루트 엔드포인트 - 헬스 체크"""
    return {
        "message": f"Welcome to {settings.app_name}",
        "environment": settings.app_env,
        "version": "0.1.0",
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """헬스 체크 엔드포인트"""
    return {
        "status": "healthy",
        "app_name": settings.app_name,
        "environment": settings.app_env,
    }



