"""
Solar Eye Backend - Configuration Module

Pydantic Settings 기반 환경 변수 관리
개발/스테이징/프로덕션 환경 분리 지원
"""

from functools import lru_cache
from typing import List, Optional

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """애플리케이션 설정 클래스"""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # -------------------------------------------------------------------------
    # Application Settings
    # -------------------------------------------------------------------------
    app_name: str = Field(default="solar-eye-backend", description="애플리케이션 이름")
    app_env: str = Field(default="development", description="환경 (development/staging/production)")
    debug: bool = Field(default=True, description="디버그 모드")
    secret_key: str = Field(default="dev-secret-key-change-in-production", description="시크릿 키")

    # -------------------------------------------------------------------------
    # Server Settings
    # -------------------------------------------------------------------------
    host: str = Field(default="0.0.0.0", description="서버 호스트")
    port: int = Field(default=8000, description="서버 포트")
    workers: int = Field(default=1, description="워커 수")

    # -------------------------------------------------------------------------
    # Database Settings (PostgreSQL)
    # -------------------------------------------------------------------------
    database_url: str = Field(
        default="postgresql+asyncpg://postgres:postgres@localhost:5432/solar_eye",
        description="데이터베이스 연결 URL",
    )
    postgres_user: str = Field(default="postgres", description="PostgreSQL 사용자")
    postgres_password: str = Field(default="postgres", description="PostgreSQL 비밀번호")
    postgres_db: str = Field(default="solar_eye", description="PostgreSQL 데이터베이스명")
    postgres_host: str = Field(default="localhost", description="PostgreSQL 호스트")
    postgres_port: int = Field(default=5432, description="PostgreSQL 포트")

    # -------------------------------------------------------------------------
    # Redis Settings
    # -------------------------------------------------------------------------
    redis_url: str = Field(default="redis://localhost:6379/0", description="Redis 연결 URL")
    redis_host: str = Field(default="localhost", description="Redis 호스트")
    redis_port: int = Field(default=6379, description="Redis 포트")
    redis_db: int = Field(default=0, description="Redis DB 번호")
    redis_password: Optional[str] = Field(default=None, description="Redis 비밀번호")

    # -------------------------------------------------------------------------
    # Firebase Settings
    # -------------------------------------------------------------------------
    firebase_project_id: Optional[str] = Field(default=None, description="Firebase 프로젝트 ID")
    firebase_credentials_path: Optional[str] = Field(
        default=None, description="Firebase 인증 파일 경로"
    )

    # -------------------------------------------------------------------------
    # Weather API Settings (기상청)
    # -------------------------------------------------------------------------
    weather_api_key: Optional[str] = Field(default=None, description="기상청 API 키")
    weather_api_base_url: str = Field(
        default="http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0",
        description="기상청 API 기본 URL",
    )

    # -------------------------------------------------------------------------
    # AI Model Settings
    # -------------------------------------------------------------------------
    ai_model_path: str = Field(default="models/", description="AI 모델 경로")
    use_gpu: bool = Field(default=True, description="GPU 사용 여부")
    gpu_device_id: int = Field(default=0, description="GPU 디바이스 ID")
    fp16_enabled: bool = Field(default=True, description="FP16 최적화 사용")

    # -------------------------------------------------------------------------
    # CORS Settings
    # -------------------------------------------------------------------------
    cors_origins: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:8080"],
        description="허용된 CORS 오리진",
    )
    cors_allow_credentials: bool = Field(default=True, description="CORS 인증 허용")

    # -------------------------------------------------------------------------
    # Logging Settings
    # -------------------------------------------------------------------------
    log_level: str = Field(default="DEBUG", description="로그 레벨")
    log_format: str = Field(default="json", description="로그 포맷 (json/text)")
    log_file_path: Optional[str] = Field(default="logs/app.log", description="로그 파일 경로")

    # -------------------------------------------------------------------------
    # Storage Settings
    # -------------------------------------------------------------------------
    upload_dir: str = Field(default="uploads/", description="업로드 디렉토리")
    snapshot_dir: str = Field(default="snapshots/", description="스냅샷 디렉토리")
    max_upload_size: int = Field(default=104857600, description="최대 업로드 크기 (bytes)")

    # -------------------------------------------------------------------------
    # Stream Processing Settings
    # -------------------------------------------------------------------------
    stream_fps: float = Field(default=1.0, description="스트림 프레임 추출 속도 (FPS)")
    stream_reconnect_interval: float = Field(default=5.0, description="스트림 재연결 간격 (초)")
    stream_max_reconnect_attempts: int = Field(default=5, description="최대 재연결 시도 횟수")
    stream_connection_timeout: float = Field(default=10.0, description="스트림 연결 타임아웃 (초)")
    
    # -------------------------------------------------------------------------
    # Scheduler Settings
    # -------------------------------------------------------------------------
    daily_report_hour: int = Field(default=20, description="일간 리포트 생성 시각 (시)")
    daily_report_minute: int = Field(default=0, description="일간 리포트 생성 시각 (분)")
    stream_monitor_interval: float = Field(default=60.0, description="스트림 모니터링 간격 (초)")

    # -------------------------------------------------------------------------
    # Gemini AI Settings
    # -------------------------------------------------------------------------
    gemini_api_key: Optional[str] = Field(default=None, description="Gemini API 키")

    # -------------------------------------------------------------------------
    # Validators
    # -------------------------------------------------------------------------
    @field_validator("app_env")
    @classmethod
    def validate_app_env(cls, v: str) -> str:
        allowed = {"development", "staging", "production"}
        if v not in allowed:
            raise ValueError(f"app_env must be one of {allowed}")
        return v

    @field_validator("log_level")
    @classmethod
    def validate_log_level(cls, v: str) -> str:
        allowed = {"DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"}
        v_upper = v.upper()
        if v_upper not in allowed:
            raise ValueError(f"log_level must be one of {allowed}")
        return v_upper

    # -------------------------------------------------------------------------
    # Properties
    # -------------------------------------------------------------------------
    @property
    def is_development(self) -> bool:
        """개발 환경 여부"""
        return self.app_env == "development"

    @property
    def is_production(self) -> bool:
        """프로덕션 환경 여부"""
        return self.app_env == "production"

    @property
    def is_staging(self) -> bool:
        """스테이징 환경 여부"""
        return self.app_env == "staging"

    def get_database_url(self) -> str:
        """데이터베이스 URL 반환 (Cloud SQL 소켓 지원)"""
        # 환경변수 DATABASE_URL이 설정되어 있으면 우선 사용
        if self.database_url and not self.database_url.startswith("postgresql+asyncpg://postgres:postgres@localhost"):
            return self.database_url
        
        # Cloud SQL Unix 소켓 연결 (Cloud Run에서 사용)
        # DB_HOST가 /cloudsql/로 시작하면 Unix 소켓 사용
        if self.postgres_host.startswith("/cloudsql/"):
            # asyncpg Unix socket format: postgresql+asyncpg://user:pass@/dbname?host=/cloudsql/...
            return (
                f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}"
                f"@/{self.postgres_db}?host={self.postgres_host}"
            )
        
        # 일반 TCP 연결
        return (
            f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )


@lru_cache()
def get_settings() -> Settings:
    """
    설정 인스턴스 반환 (캐시됨)
    
    FastAPI 의존성 주입에서 사용:
        from app.config import get_settings
        settings = Depends(get_settings)
    """
    return Settings()


# 전역 설정 인스턴스 (편의를 위해)
settings = get_settings()
