#!/bin/bash
# Solar Eye Backend - VM 초기 설정 스크립트

echo "🔧 Solar Eye Backend VM 초기 설정 시작..."

# Python 가상환경 생성 (선택사항)
if [ ! -d "venv" ]; then
    echo "📦 Python 가상환경 생성 중..."
    python3 -m venv venv
fi

# 가상환경 활성화
source venv/bin/activate

# 의존성 설치
echo "📥 Python 패키지 설치 중..."
pip install --upgrade pip
pip install -r requirements.txt

# NVIDIA GPU 확인
echo "🔍 GPU 확인..."
nvidia-smi

# 데이터베이스 마이그레이션
echo "🗄️ 데이터베이스 마이그레이션..."
alembic upgrade head

# 시드 데이터 삽입 (선택사항)
# python scripts/seed_data.py

echo "✅ 초기 설정 완료!"
echo "서버 시작: ./scripts/start_server.sh"
