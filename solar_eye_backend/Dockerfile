# =============================================================================
# Solar Eye Backend - Dockerfile (Production)
# =============================================================================
# GPU 지원 및 AI 파이프라인을 위한 프로덕션 이미지
# =============================================================================
# Force Rebuild: 2026-02-06
# 1. Base Image
# GPU 사용을 위해 NVIDIA CUDA 이미지 사용 (Ubuntu 22.04 includes Python 3.10)
# GPU 사용을 위해 NVIDIA CUDA 이미지 사용 (빌드 호환성을 위해 devel 이미지 권장)
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# 2. Build Arguments
ARG DEBIAN_FRONTEND=noninteractive

# 3. System Dependencies
# Python 및 필수 패키지 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
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
    # 네트워크 및 빌드 도구
    curl \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python 별칭 설정 (python -> python3)
RUN ln -s /usr/bin/python3 /usr/bin/python

# 4. Work Directory
WORKDIR /app

# 5. Install Python Dependencies
# 캐싱 효율을 위해 requirements.txt 먼저 복사
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir -r requirements.txt

# 6. Apply basicsr compatibility patch
# torchvision 0.17+ 대응을 위한 import 수정 (find 명령어로 위치 자동 검색)
RUN find /usr/local/lib/python3* -name degradations.py -exec sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/g' {} + || echo "Warning: basicsr patch skipped"

# 7. Copy Application Code
COPY . .

# 7. Create directories for uploads and snapshots
RUN mkdir -p uploads snapshots logs && chmod 777 uploads snapshots logs

# 8. Expose Port
EXPOSE 8000

# 9. Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 10. Run Application
# Gunicorn + Uvicorn workers for production
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
