# Solar Eye 팀원 개발 환경 설정 가이드

> **목적:** Solar Eye 백엔드 API 테스트를 위한 환경 설정 가이드  
> **작성일:** 2026.01.19

---

## 📋 사전 준비물

| 항목 | 설명 | 공유 방법 |
|------|------|----------|
| **소스 코드** | GitHub 저장소 | `git pull` |
| **Firebase 서비스 계정 키** | `*firebase*.json` 파일 | 🔒 DM으로 별도 공유 |
| **Docker Desktop** | PostgreSQL, Redis 실행용 | 각자 설치 |

---

## 🚀 설정 순서

### 1단계: 코드 받기
```bash
git pull origin develop
cd solar_eye/solar_eye_backend
```

### 2단계: 환경 변수 설정
```bash
# .env.example을 복사하여 .env 생성
cp .env.example .env
```

`.env` 파일에서 수정할 항목:
```env
# Firebase 설정 (공유받은 JSON 파일 경로로 수정)
FIREBASE_PROJECT_ID=solar-eye-56f78
FIREBASE_CREDENTIALS_PATH=../solar-eye-56f78-firebase-adminsdk-xxxxx.json
```

### 3단계: Firebase JSON 파일 배치
- DM으로 공유받은 JSON 파일을 `solar_eye/` 폴더에 저장
- ⚠️ **절대 GitHub에 커밋하지 마세요!** (`.gitignore`에 이미 추가됨)

### 4단계: Docker 컨테이너 실행
```bash
# Docker Desktop 실행 후
docker-compose -f docker/docker-compose.yml up -d
```

### 5단계: 백엔드 서버 실행
```bash
cd solar_eye_backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 🔑 Firebase 토큰 발급 (API 테스트용)

### 1. 토큰 발급 페이지 실행
```bash
# solar_eye 폴더에서
python -m http.server 3000
```

### 2. 브라우저에서 접속
```
http://localhost:3000/firebase_token_test.html
```

### 3. Google 로그인 → 토큰 복사

---

## 🧪 API 테스트

### Swagger UI 접속
```
http://localhost:8000/docs
```

### 소셜 로그인 테스트 예시

1. `POST /api/v1/auth/login` 선택
2. "Try it out" 클릭
3. Request body에 토큰 입력:
```json
{
  "id_token": "발급받은_토큰_붙여넣기"
}
```
4. "Execute" 클릭

### 성공 응답
```json
{
  "success": true,
  "message": "회원가입 및 로그인 성공",
  "data": {
    "user": { ... },
    "isNewUser": true
  }
}
```

---

## ⚠️ 주의사항

| 항목 | 설명 |
|------|------|
| **토큰 유효기간** | 1시간 (만료 시 재발급 필요) |
| **Firebase JSON** | 절대 GitHub 커밋 금지 🚫 |
| **Docker** | 서버 실행 전 반드시 컨테이너 실행 필요 |

---

## 📞 문제 해결

| 에러 | 해결 방법 |
|------|----------|
| `auth/configuration-not-found` | Firebase Console에서 Google 로그인 활성화 |
| `Docker connection failed` | Docker Desktop 실행 확인 |
| `Token expired` | 토큰 발급 페이지에서 재발급 |
| `422 Validation Error` | Request Body 형식 확인 (Header가 아닌 Body에 토큰) |

---

## 🔗 관련 링크

- [Firebase Console](https://console.firebase.google.com)
- [Swagger UI](http://localhost:8000/docs) (서버 실행 후)
- [토큰 발급 페이지](http://localhost:3000/firebase_token_test.html)
