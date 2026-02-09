import asyncio
import os
import sys
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, delete

# Add parent directory to sys.path
sys.path.append(os.getcwd())

try:
    from app.config import settings
    from app.models.user import User
    from app.models.panel import Panel
    from app.models.detection import Detection
    from app.models.daily_report import DailyReport
    from app.models.analysis import AnalysisSession
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def cleanup_seed():
    TARGET_EMAIL = "edu_164@iceu.kr"
    
    async with AsyncSessionLocal() as db:
        print(f"🧹 Cleaning up seeded data for {TARGET_EMAIL}...")
        
        result = await db.execute(select(User).where(User.email == TARGET_EMAIL))
        user = result.scalar_one_or_none()
        
        if user:
            # Delete panels (cascades might handle reports/detections, but let's be explicit if needed)
            # Actually, we want to keep the USER but delete the PANELS we just seeded.
            # However, if the user "never created a panel", maybe the panels were the problem.
            
            # Delete Analysis Sessions for target panels
            # We need to distinguish between "seeded" sessions and "user-created" ones.
            # Seeded ones won't have the analysis_id format from real analysis usually.
            
            print(f"Found user ID: {user.id}. Deleting associated panels...")
            await db.execute(delete(Panel).where(Panel.user_id == user.id))
            await db.commit()
            print("✅ Seeded panels deleted.")
        else:
            print("User not found.")

if __name__ == "__main__":
    asyncio.run(cleanup_seed())
