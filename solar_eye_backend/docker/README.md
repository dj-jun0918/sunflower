# Solar Eye Backend - Docker Configuration

Docker를 사용하여 Solar Eye 백엔드 서비스를 컨테이너화합니다.

---

## 📁 파일 구조

| 파일 | 설명 |
|------|------|
| `Dockerfile` | 프로덕션용 이미지 (FFmpeg, Health Check 포함) |
| `Dockerfile.dev` | 개발용 이미지 (Hot Reload, Debugpy 포함) |
| `docker-compose.yml` | 전체 스택 구성 (Backend + PostgreSQL + Redis) |
| `docker-compose.dev.yml` | 개발 환경 오버라이드 |

---

## 🚀 실행 방법

### 프로덕션 모드

```bash
# 전체 서비스 시작
docker-compose up -d

# 백엔드만 빌드 후 시작
docker-compose up -d --build backend

# 로그 확인
docker-compose logs -f backend

# 서비스 중지
docker-compose down

# 볼륨 포함 전체 삭제
docker-compose down -v
```

### 개발 모드 (Hot Reload)

```bash
# 개발 모드 시작 (두 파일 합성)
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# 백그라운드 실행
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

---

## 🔧 서비스 구성

| 서비스 | 포트 | 설명 |
|--------|------|------|
| `backend` | 8000 | FastAPI 백엔드 서버 |
| `postgres` | 5432 | PostgreSQL 데이터베이스 |
| `redis` | 6379 | Redis 캐시 서버 |
| `test-tool` | 8080 | Firebase 토큰 테스트 도구 |

---

## 📋 환경 변수

`.env` 파일에서 설정 가능한 주요 변수:

```env
# 서버
PORT=8000
DEBUG=true

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=solar_eye
POSTGRES_PORT=5432

# Redis
REDIS_PORT=6379

# Firebase
FIREBASE_CREDENTIALS_PATH=/app/firebase-credentials.json
```

---

## 🛠️ 개발 팁

### 컨테이너 접속

```bash
# 백엔드 컨테이너 셸 접속
docker exec -it solar_eye_backend bash

# PostgreSQL 접속
docker exec -it solar_eye_postgres psql -U postgres -d solar_eye
```

### 마이그레이션 실행

```bash
docker exec -it solar_eye_backend alembic upgrade head
```

### 디버깅 (VS Code)

개발 모드에서 5678 포트로 debugpy 연결 가능:

```json
// .vscode/launch.json
{
  "name": "Docker: Python",
  "type": "python",
  "request": "attach",
  "connect": {
    "host": "localhost",
    "port": 5678
  }
}
```

---

## 📊 Health Check

프로덕션 Dockerfile에 Health Check 포함:

```
GET http://localhost:8000/health
```

응답:
```json
{
  "status": "healthy",
  "app_name": "solar-eye-backend",
  "environment": "production"
}
```
