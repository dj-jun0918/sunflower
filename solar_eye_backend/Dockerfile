# =============================================================================
# Solar Eye Backend - Dockerfile (Production)
# =============================================================================
# TensorFlow GPU 공식 이미지 기반 - JIT 컴파일 문제 해결
# =============================================================================
# Force Rebuild: 2026-02-10 (TensorFlow Official GPU Image)

# 1. Base Image - TensorFlow 공식 GPU 이미지
# CUDA 커널이 미리 컴파일되어 있어서 JIT 컴파일 지연 없음
FROM tensorflow/tensorflow:2.16.1-gpu

# 2. Build Arguments
ARG DEBIAN_FRONTEND=noninteractive

# 3. System Dependencies
# TensorFlow 이미지에 포함되지 않은 패키지 설치
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
    # 네트워크 및 빌드 도구
    curl \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. Work Directory
WORKDIR /app

# 5. Install Python Dependencies
# TensorFlow와 Keras는 베이스 이미지에 포함되어 있으므로 requirements에서 제외됨
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 6. Apply basicsr compatibility patch
# torchvision 0.17+ 대응을 위한 import 수정
RUN find /usr/local/lib/python3* -name degradations.py -exec sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/g' {} + || echo "Warning: basicsr patch skipped"

# 7. Copy Application Code
COPY . .

# 8. Create directories for uploads and snapshots
RUN mkdir -p uploads snapshots logs && chmod 777 uploads snapshots logs

# 9. Expose Port
# Cloud Run sets the PORT environment variable (default 8080)
ENV PORT=8080
EXPOSE ${PORT}

# 10. Health Check
# GPU 이미지로 변경하여 start-period 단축 가능
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# 11. Run Application
CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --workers 1
