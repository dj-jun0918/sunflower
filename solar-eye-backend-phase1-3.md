# Solar Eye Backend - Phase 1~3 작업 완료 보고서

> **작성일:** 2026.01.16  
> **프로젝트:** Solar Eye Backend API  
> **기술 스택:** Python 3.10+, FastAPI, PostgreSQL, Redis, Docker

---

## 📌 Phase 1: 프로젝트 셋업 및 기반 구축 ✅

### 1.1 프로젝트 초기화

#### 생성된 파일

| 파일 | 설명 |
|:---|:---|
| `pyproject.toml` | 프로젝트 메타데이터 및 의존성 정의 |
| `requirements.txt` | pip 설치용 의존성 목록 |
| `.gitignore` | Git 추적 제외 파일 설정 |
| `.env.example` | 환경 변수 템플릿 |

#### requirements.txt 주요 의존성

```txt
fastapi>=0.115.0
uvicorn[standard]>=0.32.0
gunicorn>=23.0.0
pydantic>=2.9.0
pydantic-settings>=2.6.0
sqlalchemy>=2.0.36
asyncpg>=0.30.0
alembic>=1.14.0
redis>=5.2.0
firebase-admin>=6.6.0
python-jose[cryptography]>=3.3.0
torch>=2.5.0
opencv-python>=4.10.0
av>=13.0.0
httpx>=0.28.0
python-multipart>=0.0.19
python-dotenv>=1.0.1
aiofiles>=24.0.0
```

### 1.2 프로젝트 디렉토리 구조

```
solar_eye_backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI 애플리케이션 엔트리포인트
│   ├── config.py            # Pydantic Settings 환경 변수 관리
│   ├── api/                  # API 라우터 (추후 구현)
│   │   └── __init__.py
│   ├── core/                 # 핵심 모듈 (인증, Redis 등)
│   │   └── __init__.py
│   ├── db/                   # 데이터베이스 설정
│   │   ├── __init__.py
│   │   ├── base.py          # SQLAlchemy Base 모델
│   │   └── session.py       # 비동기 DB 세션 관리
│   ├── models/               # SQLAlchemy 모델
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── panel.py
│   │   ├── detection.py
│   │   ├── alert.py
│   │   └── daily_report.py
│   ├── schemas/              # Pydantic 스키마 (추후 구현)
│   │   └── __init__.py
│   ├── services/             # 비즈니스 로직 (추후 구현)
│   │   └── __init__.py
│   └── ai/                   # AI 파이프라인 (추후 구현)
│       └── __init__.py
├── alembic/                  # 데이터베이스 마이그레이션
│   ├── env.py               # Alembic 환경 설정 (비동기)
│   ├── script.py.mako
│   └── versions/
│       └── 6d515a4d8513_initial_migration_create_all_tables.py
├── docker/
│   └── docker-compose.yml   # PostgreSQL + Redis 컨테이너
├── tests/
│   └── __init__.py
└── .env.example
```

### 1.3 환경 변수 설정 (`app/config.py`)

Pydantic Settings를 사용한 타입 안전 환경 변수 관리:

```python
class Settings(BaseSettings):
    # Application
    app_name: str = "solar-eye-backend"
    app_env: str = "development"  # development | staging | production
    debug: bool = True
    
    # Database (PostgreSQL)
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/solar_eye"
    
    # Redis
    redis_url: str = "redis://localhost:6379/0"
    
    # Firebase
    firebase_project_id: Optional[str] = None
    firebase_credentials_path: Optional[str] = None
    
    # Weather API (기상청)
    weather_api_key: Optional[str] = None
    
    # AI Model
    ai_model_path: str = "models/"
    use_gpu: bool = True
    fp16_enabled: bool = True
    
    # CORS
    cors_origins: List[str] = ["http://localhost:3000", "http://localhost:8080"]
```

**특징:**
- 환경별 설정 분리 (`is_development`, `is_production`, `is_staging` 프로퍼티)
- 환경 변수 유효성 검증 (`@field_validator`)
- `.env` 파일 자동 로드

---

## 📌 Phase 2: 데이터베이스 설계 및 구축 ✅

### 2.1 PostgreSQL + Docker Compose

**docker/docker-compose.yml:**

```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: solar_eye_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: solar_eye
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d solar_eye"]

  redis:
    image: redis:7-alpine
    container_name: solar_eye_redis
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
```

**실행 명령:**
```powershell
cd docker
docker compose up -d
```

### 2.2 SQLAlchemy 모델

#### 2.2.1 User 모델 (`app/models/user.py`)

| 컬럼 | 타입 | 설명 |
|:---|:---|:---|
| `id` | Integer | PK, Auto Increment |
| `firebase_uid` | String(128) | Firebase UID (Unique, Index) |
| `email` | String(255) | 이메일 (Unique, Index) |
| `display_name` | String(100) | 표시 이름 |
| `photo_url` | Text | 프로필 이미지 URL |
| `provider` | String(20) | 인증 제공자 (google/apple/kakao) |
| `notification_enabled` | Boolean | 푸시 알림 활성화 |
| `fcm_token` | Text | FCM 토큰 |
| `last_login_at` | DateTime(TZ) | 마지막 로그인 |
| `is_active` | Boolean | 계정 활성화 상태 |
| `created_at` | DateTime(TZ) | 생성 일시 |
| `updated_at` | DateTime(TZ) | 수정 일시 |

**관계:** `panels` (1:N), `alerts` (1:N)

#### 2.2.2 Panel 모델 (`app/models/panel.py`)

| 컬럼 | 타입 | 설명 |
|:---|:---|:---|
| `id` | Integer | PK |
| `user_id` | Integer | FK → users.id |
| `name` | String(100) | 패널/발전소 이름 |
| `description` | Text | 설명 |
| `location` | String(255) | 주소 |
| `rtsp_url` | Text | RTSP 스트림 URL |
| `status` | String(20) | 상태 (active/inactive/error/maintenance) |
| `latitude` | Float | 위도 |
| `longitude` | Float | 경도 |
| `grid_nx` | Integer | 기상청 격자 X |
| `grid_ny` | Integer | 기상청 격자 Y |
| `capacity_kw` | Float | 발전 용량 (kW) |
| `panel_count` | Integer | 패널 개수 |
| `thumbnail_url` | Text | 대표 이미지 |

**관계:** `user` (N:1), `detections` (1:N), `daily_reports` (1:N)

#### 2.2.3 Detection 모델 (`app/models/detection.py`)

| 컬럼 | 타입 | 설명 |
|:---|:---|:---|
| `id` | Integer | PK |
| `panel_id` | Integer | FK → panels.id |
| `defect_type` | String(20) | 결함 유형 (defect/soiling/normal) |
| `defect_subtype` | String(30) | 결함 세부 유형 |
| `confidence` | Float | 신뢰도 (0.0~1.0) |
| `bbox_x`, `bbox_y` | Integer | 바운딩 박스 좌표 |
| `bbox_width`, `bbox_height` | Integer | 바운딩 박스 크기 |
| `snapshot_url` | Text | 스냅샷 URL |
| `frame_number` | Integer | 프레임 번호 |
| `area_percentage` | Float | 결함 영역 비율 (%) |
| `detected_at` | DateTime(TZ) | 탐지 일시 |

**관계:** `panel` (N:1), `alerts` (1:N)

#### 2.2.4 Alert 모델 (`app/models/alert.py`)

| 컬럼 | 타입 | 설명 |
|:---|:---|:---|
| `id` | Integer | PK |
| `detection_id` | Integer | FK → detections.id (Optional) |
| `user_id` | Integer | FK → users.id |
| `alert_type` | String(20) | 알림 유형 |
| `title` | String(200) | 알림 제목 |
| `message` | Text | 알림 내용 |
| `image_url` | Text | 알림 이미지 |
| `deep_link` | String(500) | 딥링크 URL |
| `is_read` | Boolean | 읽음 여부 |
| `sent_at` | DateTime(TZ) | 발송 일시 |
| `read_at` | DateTime(TZ) | 읽음 일시 |

**관계:** `detection` (N:1), `user` (N:1)

#### 2.2.5 DailyReport 모델 (`app/models/daily_report.py`)

| 컬럼 | 타입 | 설명 |
|:---|:---|:---|
| `id` | Integer | PK |
| `panel_id` | Integer | FK → panels.id |
| `report_date` | Date | 리포트 날짜 |
| `total_detections` | Integer | 총 탐지 건수 |
| `total_defects` | Integer | 결함 탐지 건수 |
| `total_soiling` | Integer | 오염 탐지 건수 |
| `avg_soiling_area` | Float | 평균 오염 영역 비율 (%) |
| `max_soiling_area` | Float | 최대 오염 영역 비율 (%) |
| `estimated_loss_kwh` | Float | 추정 발전 손실량 (kWh) |
| `estimated_loss_krw` | Float | 추정 손실 금액 (원) |
| `cleaning_recommended` | Boolean | 청소 권고 여부 |
| `weather_summary` | Text | 날씨 요약 |
| `had_rain` | Boolean | 강우 발생 여부 |
| `summary` | JSONB | 상세 요약 데이터 |

**관계:** `panel` (N:1)

### 2.3 비동기 DB 세션 (`app/db/session.py`)

```python
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

engine = create_async_engine(
    settings.get_database_url(),
    echo=settings.debug,
    pool_pre_ping=True,
)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

### 2.4 Alembic 마이그레이션

**비동기 설정 (`alembic/env.py`):**
- `async_engine_from_config` 사용
- 모든 모델 자동 import

**마이그레이션 명령:**
```powershell
# 마이그레이션 생성
alembic revision --autogenerate -m "설명"

# 마이그레이션 적용
alembic upgrade head

# 현재 상태 확인
alembic current

# 이력 확인
alembic history
```

**생성된 테이블:**
| 테이블 | 설명 |
|:---|:---|
| `users` | 사용자 |
| `panels` | 태양광 패널/발전소 |
| `detections` | AI 탐지 결과 |
| `alerts` | 푸시 알림 |
| `daily_reports` | 일간 리포트 |
| `alembic_version` | 마이그레이션 버전 |

---

## 📌 Phase 3: 핵심 인프라 구축 ✅

### 3.1 FastAPI 앱 설정 (`app/main.py`)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print(f"🚀 Starting {settings.app_name} in {settings.app_env} mode...")
    # TODO: DB 연결 초기화
    # TODO: Redis 연결 초기화
    # TODO: Firebase 초기화
    
    yield
    
    # Shutdown
    print(f"🛑 Shutting down {settings.app_name}...")

app = FastAPI(
    title=settings.app_name,
    description="AI-powered Solar Panel Defect Detection Backend API",
    version="0.1.0",
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    lifespan=lifespan,
)

# CORS 미들웨어
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### 3.2 현재 구현된 API 엔드포인트

| 엔드포인트 | 메서드 | 설명 |
|:---|:---|:---|
| `/` | GET | 루트 - 앱 정보 |
| `/health` | GET | 헬스 체크 |
| `/docs` | GET | Swagger UI (개발 모드) |
| `/redoc` | GET | ReDoc (개발 모드) |

### 3.3 서버 실행

```powershell
# 개발 서버 실행
cd solar_eye_backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 또는 Python으로 직접 실행
python -m uvicorn app.main:app --reload
```

**접속 URL:**
- API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

---

## 📊 ER 다이어그램

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   users     │       │   panels    │       │ detections  │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id (PK)     │──┐    │ id (PK)     │──┐    │ id (PK)     │
│ firebase_uid│  │    │ user_id (FK)│──┘    │ panel_id(FK)│──┐
│ email       │  │    │ name        │       │ defect_type │  │
│ display_name│  │    │ rtsp_url    │       │ confidence  │  │
│ provider    │  │    │ status      │       │ bbox_*      │  │
│ fcm_token   │  │    │ latitude    │       │ snapshot_url│  │
│ ...         │  │    │ longitude   │       │ detected_at │  │
└─────────────┘  │    │ grid_nx/ny  │       └─────────────┘  │
                 │    │ ...         │                        │
                 │    └─────────────┘                        │
                 │           │                               │
                 │    ┌──────┴──────┐                 ┌──────┴──────┐
                 │    │             │                 │             │
                 │    ▼             ▼                 ▼             │
                 │ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
                 │ │daily_reports│ │   alerts    │ │   alerts    │ │
                 │ ├─────────────┤ ├─────────────┤ │ (user 연결) │ │
                 │ │ id (PK)     │ │ id (PK)     │ ├─────────────┤ │
                 │ │ panel_id(FK)│ │detection_id │ │ user_id(FK) │◀┘
                 │ │ report_date │ │ user_id(FK) │─┘ ...         │
                 │ │ total_*     │ │ alert_type  │  └─────────────┘
                 │ │ estimated_* │ │ title       │
                 └─│ ...         │ │ is_read     │
                   └─────────────┘ └─────────────┘
```

---

## 🔜 다음 단계 (Phase 4~)

| Phase | 내용 | 상태 |
|:---|:---|:---|
| Phase 4 | Pydantic 스키마 정의 | 미완료 |
| Phase 5 | 인증 API (Firebase) | 미완료 |
| Phase 6 | 패널 API (CRUD) | 미완료 |
| Phase 7 | 탐지 API | 미완료 |
| Phase 8 | 알림 API + FCM | 미완료 |
| Phase 9 | 리포트 API | 미완료 |
| Phase 10 | 날씨 API (기상청) | 미완료 |
| Phase 11 | AI 엔진 통합 | 미완료 |

---

## 📝 참고 명령어

```powershell
# Docker 시작
cd solar_eye_backend/docker
docker compose up -d

# Docker 상태 확인
docker ps --filter "name=solar_eye"

# 마이그레이션 적용
cd solar_eye_backend
alembic upgrade head

# 서버 실행
uvicorn app.main:app --reload --port 8000

# DB 테이블 확인
docker exec solar_eye_postgres psql -U postgres -d solar_eye -c "\dt"
```
