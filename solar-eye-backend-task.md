# Solar-Eye 백엔드 개발 태스크 목록

> **목표:** FastAPI 기반 Solar-Eye 백엔드 API 서버 구현  
> **기술 스택:** Python 3.10+, FastAPI, PostgreSQL, Redis, Docker  
> **작성일:** 2026.01.16  
> **1차 발표:** 2026.01.28 (화)  
> **최종 발표:** 2026.02.11 ~ 02.13

---

## 📌 Phase 1: 프로젝트 셋업 및 기반 구축 (Day 1-2) ✅ **완료**

### 1.1 프로젝트 초기화
- [x] 프로젝트 디렉토리 생성 (`solar_eye_backend/`)
- [x] Python 가상환경 설정 (venv 또는 poetry)
- [x] `pyproject.toml` 작성
- [x] `requirements.txt` 작성
  ```
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

### 1.2 프로젝트 구조 설정
- [x] Clean Architecture 기반 디렉토리 구조 생성
  ```
  solar_eye_backend/
  ├── app/
  │   ├── __init__.py
  │   ├── main.py
  │   ├── config.py
  │   ├── api/
  │   ├── core/
  │   ├── models/
  │   ├── schemas/
  │   ├── services/
  │   ├── ai/
  │   └── db/
  ├── tests/
  ├── alembic/
  ├── docker/
  └── .env.example
  ```

### 1.3 환경 설정
- [x] `.env.example` 파일 생성
- [x] `app/config.py` - Pydantic Settings 기반 환경 변수 관리
- [x] `.gitignore` 설정 (venv, .env, __pycache__ 등)
- [x] 개발/프로덕션 환경 분리

---

## 📌 Phase 2: 데이터베이스 설계 및 구축 (Day 2-3) ⭐ 최우선 ✅ **완료**

### 2.1 PostgreSQL 설정
- [x] Docker Compose로 PostgreSQL 컨테이너 설정
- [x] `app/db/session.py` - 비동기 DB 세션 관리
- [x] `app/db/base.py` - Base 모델 정의

### 2.2 SQLAlchemy 모델 정의 (`app/models/`)
- [x] `user.py` - 사용자 모델
  - [x] id, firebase_uid, email, display_name, provider
  - [x] notification_enabled, fcm_token
  - [x] created_at, last_login_at
- [x] `panel.py` - 패널/발전소 모델
  - [x] id, user_id (FK), name, location
  - [x] rtsp_url, status (active/inactive/error)
  - [x] latitude, longitude, grid_nx, grid_ny
  - [x] created_at, updated_at
- [x] `detection.py` - 탐지 결과 모델
  - [x] id, panel_id (FK), defect_type (Enum)
  - [x] defect_subtype, confidence
  - [x] bbox_x, bbox_y, bbox_width, bbox_height
  - [x] snapshot_url, detected_at
- [x] `alert.py` - 알림 모델
  - [x] id, detection_id (FK), user_id (FK)
  - [x] alert_type, title, message
  - [x] is_read, sent_at, read_at
- [x] `daily_report.py` - 일간 리포트 모델
  - [x] id, panel_id (FK), report_date
  - [x] total_defects, total_soiling
  - [x] estimated_loss, summary (JSON)

### 2.3 Alembic 마이그레이션 설정
- [x] Alembic 초기화 (`alembic init`)
- [x] `alembic/env.py` 비동기 설정
- [x] 초기 마이그레이션 생성 (DB 실행 후 진행) ✅
- [x] 마이그레이션 실행 (DB 실행 후 진행) ✅

---

## 📌 Phase 3: 핵심 인프라 구축 (Day 3-4) ✅ **완료**

### 3.1 FastAPI 앱 설정 (`app/main.py`)
- [x] FastAPI 앱 인스턴스 생성 ✅
- [x] CORS 미들웨어 설정 ✅
- [x] 라이프사이클 이벤트 (startup/shutdown) ✅
- [x] 에러 핸들러 설정 ✅
- [x] API 라우터 등록 (Phase 5-10에서 구현)

### 3.2 Firebase 연동 (`app/core/`)
- [x] `firebase.py` - Firebase Admin SDK 초기화 ✅
- [x] `security.py` - Firebase ID Token 검증 ✅
  - [x] `get_current_user` 의존성 함수 ✅
  - [x] 토큰 검증 및 사용자 정보 추출 ✅

### 3.3 Redis 설정
- [x] Docker Compose로 Redis 컨테이너 설정 ✅
- [x] `app/core/redis.py` - Redis 클라이언트 설정 ✅
- [x] 캐시 키 패턴 정의 ✅

### 3.4 공통 의존성 (`app/api/deps.py`)
- [x] DB 세션 의존성 ✅
- [x] 현재 사용자 의존성 ✅
- [x] Redis 클라이언트 의존성 ✅

---

## 📌 Phase 4: Pydantic 스키마 정의 (Day 4) ✅ **완료**

### 4.1 요청/응답 스키마 (`app/schemas/`)
- [x] `common.py` - 공통 스키마 ✅
  - [x] SuccessResponse, ErrorResponse ✅
  - [x] PaginationParams, PaginationMeta ✅
- [x] `user.py` - 사용자 스키마 ✅
  - [x] UserCreate, UserResponse, UserUpdate ✅
  - [x] LoginRequest, FCMTokenRequest ✅
- [x] `panel.py` - 패널 스키마 ✅
  - [x] PanelCreate, PanelResponse, PanelUpdate ✅
  - [x] PanelStatus, PanelDetail ✅
- [x] `detection.py` - 탐지 스키마 ✅
  - [x] DetectionResponse, DetectionDetail ✅
  - [x] DetectionFilter (query params) ✅
  - [x] BoundingBox ✅
- [x] `alert.py` - 알림 스키마 ✅
  - [x] AlertResponse, AlertList ✅
  - [x] AlertFilter ✅
- [x] `report.py` - 리포트 스키마 ✅
  - [x] DailyReportResponse, WeeklyReportResponse ✅
  - [x] EconomicReportResponse ✅
- [x] `weather.py` - 날씨 스키마 ✅
  - [x] CurrentWeatherResponse, ForecastResponse ✅
  - [x] WeatherStatus ✅

---

## 📌 Phase 5: 인증 API 구현 (Day 4-5) ⭐ 1차 발표 필수 ✅ **완료**

### 5.1 인증 서비스 (`app/services/auth_service.py`)
- [x] Firebase 토큰 검증 및 사용자 조회/생성 ✅
- [x] 사용자 정보 업데이트 ✅
- [x] FCM 토큰 저장 ✅

### 5.2 인증 API 라우터 (`app/api/v1/auth.py`)
- [x] `POST /api/v1/auth/login` - 소셜 로그인 ✅
  - [x] Firebase ID Token 검증 ✅
  - [x] 사용자 등록/조회 ✅
  - [x] 응답: 사용자 정보 ✅
- [x] `GET /api/v1/auth/me` - 현재 사용자 조회 ✅
- [x] `POST /api/v1/auth/fcm-token` - FCM 토큰 등록 ✅

---

## 📌 Phase 6: 패널 API 구현 (Day 5-6) ⭐ 1차 발표 필수 ✅ **완료**

### 6.1 패널 서비스 (`app/services/panel_service.py`)
- [x] 패널 CRUD 로직 ✅
- [x] 패널 상태 조회 (Redis 캐시) ✅
- [x] RTSP URL 유효성 검증 ✅

### 6.2 패널 API 라우터 (`app/api/v1/panels.py`)
- [x] `GET /api/v1/panels` - 패널 목록 조회 ✅
  - [x] 페이지네이션 ✅
  - [x] 상태 필터 ✅
- [x] `POST /api/v1/panels` - 패널 등록 ✅
- [x] `GET /api/v1/panels/{id}` - 패널 상세 조회 ✅
- [x] `PUT /api/v1/panels/{id}` - 패널 수정 ✅
- [x] `DELETE /api/v1/panels/{id}` - 패널 삭제 ✅
- [x] `GET /api/v1/panels/{id}/status` - 실시간 상태 조회 ✅

---

## 📌 Phase 7: 탐지 API 구현 (Day 6-7) ✅ **완료**

### 7.1 탐지 서비스 (`app/services/detection_service.py`)
- [x] 탐지 결과 저장 ✅
- [x] 탐지 이력 조회 (필터링, 페이지네이션) ✅
- [x] 탐지 상세 조회 ✅

### 7.2 탐지 API 라우터 (`app/api/v1/detections.py`)
- [x] `GET /api/v1/detections` - 탐지 이력 조회 ✅
  - [x] panel_id, defect_type, 날짜 필터 ✅
  - [x] 신뢰도 필터 ✅
  - [x] 페이지네이션 ✅
- [x] `GET /api/v1/detections/{id}` - 탐지 상세 조회 ✅

---

## 📌 Phase 8: 알림 API 구현 (Day 7-8) ✅ **완료**

### 8.1 알림 서비스 (`app/services/alert_service.py`)
- [x] 알림 생성 (탐지 결과 기반) ✅
- [x] 알림 목록 조회 ✅
- [x] 읽음 처리 ✅
- [x] FCM 푸시 발송 ✅

### 8.2 FCM 연동 (`app/core/fcm.py`)
- [x] FCM 푸시 알림 발송 함수 ✅
- [x] 알림 페이로드 구성 ✅
- [x] 이미지 포함 알림 ✅

### 8.3 알림 API 라우터 (`app/api/v1/alerts.py`)
- [x] `GET /api/v1/alerts` - 알림 목록 조회 ✅
  - [x] 읽음/안읽음 필터 ✅
  - [x] 알림 유형 필터 ✅
  - [x] 읽지 않은 알림 개수 ✅
- [x] `PUT /api/v1/alerts/{id}/read` - 알림 읽음 처리 ✅
- [x] `PUT /api/v1/alerts/read-all` - 전체 읽음 처리 ✅

---

## 📌 Phase 9: 리포트 API 구현 (Day 8-9) ✅ **완료**

### 9.1 리포트 서비스 (`app/services/report_service.py`)
- [x] 일간 리포트 생성/조회 ✅
- [x] 주간 리포트 집계 ✅
- [x] 경제성 분석 계산 ✅
  - [x] 오염 면적 → 효율 손실 추정 ✅
  - [x] 손실 비용 vs 청소 비용 비교 ✅
  - [x] 청소 권고 로직 ✅

### 9.2 리포트 API 라우터 (`app/api/v1/reports.py`)
- [x] `GET /api/v1/reports/daily` - 일간 리포트 ✅
- [x] `GET /api/v1/reports/weekly` - 주간 리포트 ✅
- [x] `GET /api/v1/reports/economic` - 경제성 분석 ✅

> ⚠️ **추후 수정 필요 - 경제성 분석 상수**: 현재 `report_service.py`의 경제성 분석 상수들(전력 단가, 패널 용량, 청소 비용 등)은 업계 평균 기준으로 하드코딩되어 있습니다. 실제 운영 시 환경변수 또는 패널별 설정값으로 변경하여 정확한 분석이 가능하도록 수정이 필요합니다.

---

## 📌 Phase 10: 날씨 API 구현 (Day 5-6) ⭐ 1차 발표 필수 ✅ **완료**

### 10.1 날씨 서비스 (`app/services/weather_service.py`)
- [x] 기상청 API 연동 클래스 ✅
  - [x] `getUltraSrtNcst` - 초단기실황 조회 ✅
  - [x] `getVilageFcst` - 단기예보 조회 ✅
- [x] API 응답 파싱 ✅
- [x] 위경도 → 격자 좌표 변환 ✅
- [x] Redis 캐싱 (1시간 TTL) ✅

### 10.2 날씨 API 라우터 (`app/api/v1/weather.py`)
- [x] `GET /api/v1/weather/current` - 현재 날씨 ✅
- [x] `GET /api/v1/weather/forecast` - 단기 예보 ✅
- [x] `GET /api/v1/weather/status` - 우천 여부 확인 ✅

> ⚠️ **참고 - 외부 API 키 설정**:
> - **기상청 API**: [공공데이터포털](https://www.data.go.kr)에서 "기상청_단기예보 조회서비스" API 키 발급 → `.env`에 `WEATHER_API_KEY=발급받은_키` 설정 (미설정 시 Mock 데이터 반환)
> - **Firebase**: [Firebase Console](https://console.firebase.google.com)에서 프로젝트 생성 → 서비스 계정에서 비공개 키(JSON) 다운로드 → `.env`에 `FIREBASE_PROJECT_ID`, `FIREBASE_CREDENTIALS_PATH` 설정 (인증/FCM 푸시에 필요)

---

## 📌 Phase 11: AI 엔진 통합 (Day 7-10)

### 11.1 AI 파이프라인 (`app/ai/`)
- [x] `yolo_detector.py` - YOLO ONNX 탐지 모듈 ✅
  - [x] 모델 로드 (CPU)
  - [x] 패널 영역 탐지
  - [x] 바운딩 박스 추출
- [x] `efficientnet_classifier.py` - EfficientNet 분류기 ✅
  - [x] EfficientNet 모델 로드
  - [x] 3클래스 분류 (Normal/Crack/Soiling)
  - [x] ONNX Runtime 최적화
- [x] `pipeline.py` - 2단계 파이프라인 통합 ✅
  - [x] Stage 1: YOLO 탐지
  - [x] Stage 2: EfficientNet 분류
  - [x] 결과 후처리
- [x] `analysis.py` - 이미지 분석 API ✅
  - [x] 단일 이미지 분석 엔드포인트
  - [x] 패널 스냅샷 분석 및 저장
  - [x] 알림 연동

### 11.2 RTSP 스트림 처리 (`app/ai/stream_processor.py`)
- [ ] PyAV 기반 RTSP 스트림 연결
- [ ] 프레임 추출 (1fps 또는 설정 가능)
- [ ] AI 파이프라인 연동
- [ ] 탐지 결과 저장 및 알림 트리거

### 11.3 백그라운드 작업
- [ ] 스트림 모니터링 태스크
- [ ] 일간 리포트 자동 생성 (스케줄러)

---

## 📌 Phase 12: Docker 컨테이너화 (Day 3-4)

### 12.1 Dockerfile 작성 (`docker/Dockerfile`)
- [ ] PyTorch CUDA 베이스 이미지
- [ ] 의존성 설치
- [ ] 앱 코드 복사
- [ ] Uvicorn 실행 CMD

### 12.2 Docker Compose (`docker/docker-compose.yml`)
- [ ] backend 서비스 (GPU 지원)
- [ ] PostgreSQL 서비스
- [ ] Redis 서비스
- [ ] 볼륨 및 네트워크 설정
- [ ] 환경 변수 관리

### 12.3 개발 환경 설정
- [ ] docker-compose.dev.yml (개발용)
- [ ] Hot reload 설정
- [ ] 로컬 개발 가이드 작성

---

## 📌 Phase 13: 테스트 구현 (Day 9-11)

### 13.1 테스트 환경 설정
- [ ] pytest 설정
- [ ] pytest-asyncio 설정
- [ ] 테스트 DB 설정 (SQLite 또는 테스트용 PostgreSQL)
- [ ] conftest.py - 픽스처 정의

### 13.2 단위 테스트 (`tests/`)
- [ ] `test_auth.py` - 인증 API 테스트
- [ ] `test_panels.py` - 패널 API 테스트
- [ ] `test_detections.py` - 탐지 API 테스트
- [ ] `test_alerts.py` - 알림 API 테스트
- [ ] `test_weather.py` - 날씨 API 테스트

### 13.3 통합 테스트
- [ ] 로그인 → 패널 등록 플로우
- [ ] 탐지 → 알림 생성 플로우

---

## 📌 Phase 14: 문서화 및 품질 관리 (Day 10-12)

### 14.1 API 문서화
- [ ] Swagger UI 설정 확인
- [ ] ReDoc 설정
- [ ] API 예시 응답 추가

### 14.2 코드 품질
- [ ] Black 포매터 적용
- [ ] Ruff 린터 설정
- [ ] MyPy 타입 체크
- [ ] Pre-commit 설정

### 14.3 로깅 설정
- [ ] Python logging 설정
- [ ] 로그 포맷 정의
- [ ] 로그 파일 rotation

---

## 📌 Phase 15: 배포 준비 (Day 11-13)

### 15.1 GCP 배포 준비
- [ ] GCP 프로젝트 설정
- [ ] Compute Engine 인스턴스 생성 (g2-standard-4 + L4 GPU)
- [ ] 방화벽 규칙 설정
- [ ] SSL 인증서 (Let's Encrypt)

### 15.2 Nginx 설정
- [ ] Reverse Proxy 설정
- [ ] SSL 설정
- [ ] 정적 파일 서빙

### 15.3 운영 준비
- [ ] 서버 시작 스크립트
- [ ] 헬스 체크 엔드포인트
- [ ] 모니터링 기본 설정

---

## 📋 마일스톤 체크리스트

### ⭐ 1차 발표 필수 (2026.01.28까지)
- [x] 프로젝트 구조 완성 ✅
- [x] DB 모델 및 마이그레이션 ✅
- [x] Firebase 인증 연동 ✅
- [x] 인증 API (login, me, fcm-token) ✅
- [x] 패널 API (CRUD, status) ✅
- [x] 날씨 API (기상청 연동) ✅
- [x] Docker Compose 기본 동작 ✅
- [ ] Swagger 문서 확인

### 🏁 최종 발표 (2026.02.11~13까지)
- [ ] 모든 API 엔드포인트 구현
- [ ] AI 파이프라인 통합
- [ ] RTSP 스트림 처리
- [x] FCM 푸시 알림 ✅
- [x] 경제성 분석 리포트 ✅
- [x] 우천 시 알림 중지 기능 ✅
- [ ] 통합 테스트 완료
- [ ] GCP 배포 완료

---

## 📚 참고 문서

| 문서 | 경로 |
|:---|:---|
| 앱 PRD | `solar-eye_app_prd.md` |
| 기술 스택 PRD | `solar-eye_app_tech_stack_prd.md` |
| API 명세서 | `api_specification.json` |

---

## 🔗 API 엔드포인트 요약

| 카테고리 | 엔드포인트 | 메서드 | 1차 발표 |
|:---|:---|:---|:---:|
| **인증** | `/api/v1/auth/login` | POST | ⭐ |
| | `/api/v1/auth/me` | GET | ⭐ |
| | `/api/v1/auth/fcm-token` | POST | ⭐ |
| **패널** | `/api/v1/panels` | GET/POST | ⭐ |
| | `/api/v1/panels/{id}` | GET/PUT/DELETE | ⭐ |
| | `/api/v1/panels/{id}/status` | GET | ⭐ |
| **탐지** | `/api/v1/detections` | GET | |
| | `/api/v1/detections/{id}` | GET | |
| **알림** | `/api/v1/alerts` | GET | |
| | `/api/v1/alerts/{id}/read` | PUT | |
| | `/api/v1/alerts/read-all` | PUT | |
| **리포트** | `/api/v1/reports/daily` | GET | |
| | `/api/v1/reports/weekly` | GET | |
| | `/api/v1/reports/economic` | GET | |
| **날씨** | `/api/v1/weather/current` | GET | ⭐ |
| | `/api/v1/weather/forecast` | GET | ⭐ |
| | `/api/v1/weather/status` | GET | |
