"""
데이터베이스 테스트 데이터 전체 삭제 스크립트
"""
import asyncio
import os
import sys

# 프로젝트 루트 경로 추가
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

# .env 파일 로드
from dotenv import load_dotenv
load_dotenv(os.path.join(project_root, '.env'))

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine


async def clear_all_data():
    """모든 테스트 데이터 삭제"""
    database_url = os.getenv('DATABASE_URL')
    if not database_url:
        print("❌ DATABASE_URL 환경변수가 설정되지 않았습니다.")
        return
    
    # asyncpg 형식으로 변환
    if database_url.startswith('postgresql://'):
        database_url = database_url.replace('postgresql://', 'postgresql+asyncpg://')
    
    engine = create_async_engine(database_url)
    
    async with engine.begin() as conn:
        # 외래키 순서대로 삭제
        tables = [
            'alerts',
            'daily_reports', 
            'detections',
            'panels',
            # users는 유지 (Firebase 연동)
        ]
        
        for table in tables:
            result = await conn.execute(text(f"DELETE FROM {table}"))
            print(f"✅ {table}: {result.rowcount}건 삭제됨")
        
        print("\n🗑️ 테스트 데이터 삭제 완료!")
        print("📝 users 테이블은 유지됨 (Firebase 연동)")
    
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(clear_all_data())
