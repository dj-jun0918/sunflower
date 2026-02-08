# =============================================================================
# Solar Eye Backend - Dockerfile (Production)
# =============================================================================
# GPU 지원 및 AI 파이프라인을 위한 프로덕션 이미지
# =============================================================================

# 1. Base Image
# Python 3.10 Slim 버전 (GPU는 추후 nvidia/cuda 이미지로 교체 가능)
FROM python:3.10-slim

# 2. Build Arguments
ARG DEBIAN_FRONTEND=noninteractive

# 3. System Dependencies
# OpenCV, FFmpeg(PyAV용), 기타 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    # OpenCV 의존성
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    # FFmpeg (PyAV/RTSP 스트림용)
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    # 네트워크 도구
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. Work Directory
WORKDIR /app

# 5. Install Python Dependencies
# 캐싱 효율을 위해 requirements.txt 먼저 복사
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 6. Copy Application Code
COPY . .

# 7. Verify AI Models are present (CRITICAL - fail build if missing)
RUN echo "=== Checking AI Models ===" && \
    ls -la app/ai/models/ && \
    test -f app/ai/models/yolo26m40000_weights_best.pt || (echo "ERROR: CCTV YOLO model missing!" && exit 1) && \
    test -f app/ai/models/yolo26m80k_weights_best.pt || (echo "ERROR: Drone YOLO model missing!" && exit 1) && \
    test -f app/ai/models/best_solar_model.keras || (echo "ERROR: Keras model missing!" && exit 1) && \
    echo "=== All Required AI Models Present ==="

# 8. Create directories for uploads and snapshots
RUN mkdir -p uploads snapshots logs

# 9. Expose Port
EXPOSE 8000

# 10. Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 11. Run Application
# 11. Run Application
COPY test_ai_crash.py .
CMD ["sh", "-c", "python test_ai_crash.py && gunicorn app.main:app --workers 1 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --timeout 0 --log-level debug --capture-output --enable-stdio-inheritance"]
