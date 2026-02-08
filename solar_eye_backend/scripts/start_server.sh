#!/bin/bash
# Solar Eye Backend - VM 서버 시작 스크립트

echo "🚀 Solar Eye Backend 서버 시작 중..."

# 환경 변수 로드
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ .env 파일 로드 완료"
fi

# GPU 확인
echo "🔍 GPU 확인 중..."
nvidia-smi

# Uvicorn 서버 시작 (포트 8080, 외부 접속 허용)
echo "🌐 서버 시작: http://0.0.0.0:8080"
uvicorn app.main:app --host 0.0.0.0 --port 8080 --workers 1
