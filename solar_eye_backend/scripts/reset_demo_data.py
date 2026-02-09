import asyncio
import os
import sys

# Ensure backend directory is in python path
sys.path.append(os.getcwd())

try:
    from app.config import settings
    from app.db.base import Base
    from app.models.user import User
    from app.models.panel import Panel, PanelStatus
    from app.models.detection import Detection
    from app.models.analysis import AnalysisSession
    from app.models.alert import Alert
    from app.models.daily_report import DailyReport
    from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
    from sqlalchemy.orm import sessionmaker
    from sqlalchemy import delete, update
except ImportError as e:
    print(f"Import failed: {e}")
    sys.exit(1)

# Database connection
engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def reset_demo_data():
    """
    데모 데이터를 초기화하고 모든 패널을 정상 상태로 리셋합니다.
    """
    async with AsyncSessionLocal() as db:
        print("🛑 Resetting demo data...")
        
        try:
            # 1. 탐지 결과 삭제
            print("Deleting detections...")
            await db.execute(delete(Detection))
            
            # 2. 알림 삭제
            print("Deleting alerts...")
            await db.execute(delete(Alert))
            
            # 3. 분석 세션 삭제
            print("Deleting analysis sessions...")
            await db.execute(delete(AnalysisSession))
            
            # 4. 일일 보고서 삭제
            print("Deleting daily reports...")
            await db.execute(delete(DailyReport))
            
            # 5. 모든 패널 상태를 'active'로 초기화
            print("Resetting all panel statuses to 'active'...")
            await db.execute(
                update(Panel).values(status=PanelStatus.ACTIVE.value)
            )
            
            await db.commit()
            print("✅ Reset completed successfully!")
            
        except Exception as e:
            print(f"❌ Error during reset: {e}")
            await db.rollback()
            raise

if __name__ == "__main__":
    asyncio.run(reset_demo_data())
