# Solar Eye Backend - VM 배포 가이드

## 📋 VM 생성 (GCP Console)

1. **Compute Engine → VM 인스턴스 → 만들기**
2. **설정:**
   - 이름: `solar-eye-backend-vm`
   - 리전: `asia-northeast3` (서울)
   - 영역: `asia-northeast3-a`
   - 머신 유형: `g2-standard-24` (L4 GPU x2)
   - GPU: NVIDIA L4 x 2
   - 부팅 디스크: **Deep Learning on Linux** (Ubuntu 22.04 기반, NVIDIA 드라이버 사전 설치)
   - 디스크 크기: 100GB SSD
   - 방화벽: **HTTP, HTTPS 트래픽 허용** 체크

3. **네트워킹 → 방화벽 규칙 추가:**
   - 이름: `allow-solar-eye-backend`
   - 대상: 모든 인스턴스
   - 소스 IP 범위: `0.0.0.0/0`
   - 프로토콜 및 포트: `tcp:8080`

---

## 🚀 배포 방법

### 1. VM에 SSH 접속
```bash
gcloud compute ssh solar-eye-backend-vm --zone=asia-northeast3-a
```

### 2. 파일 업로드
```bash
# 로컬에서 실행 (Cloud Shell 또는 로컬 터미널)
gcloud compute scp solar_eye_backend_v15_vm.tar solar-eye-backend-vm:~ --zone=asia-northeast3-a
```

### 3. VM에서 압축 해제 및 설정
```bash
# VM 내부에서 실행
tar -xvf solar_eye_backend_v15_vm.tar
cd solar_eye_backend

# 초기 설정 (의존성 설치)
chmod +x scripts/*.sh
./scripts/setup_vm.sh
```

### 4. .env 파일 생성
```bash
nano .env
```

**내용:**
```
DATABASE_URL=postgresql+asyncpg://user:password@localhost/solar_eye
REDIS_URL=redis://localhost:6379/0
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
DEBUG=False
APP_ENV=production
```

### 5. 서버 시작
```bash
./scripts/start_server.sh
```

---

## 🌐 외부 접속 URL 확인

```bash
# VM 외부 IP 확인
gcloud compute instances describe solar-eye-backend-vm --zone=asia-northeast3-a --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

**접속 URL:**
```
http://<외부_IP>:8080
```

---

## ✅ 프론트엔드 설정

`solar_eye_frontend/.env` 파일 수정:
```
API_BASE_URL=http://<VM_외부_IP>:8080
```
