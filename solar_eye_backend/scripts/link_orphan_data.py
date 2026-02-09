import asyncio
import os
import sys
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, update

# Add parent directory to sys.path
sys.path.append(os.getcwd())

try:
    from app.config import settings
    from app.models.user import User
    from app.models.panel import Panel
    from app.models.analysis import AnalysisSession
    from app.models.detection import Detection
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def link_data():
    TARGET_EMAIL = "edu_164@iceu.kr"
    
    async with AsyncSessionLocal() as db:
        print(f"🚀 Starting data migration for {TARGET_EMAIL}...")
        
        # 1. Get User
        res_user = await db.execute(select(User).where(User.email == TARGET_EMAIL))
        user = res_user.scalar_one_or_none()
        if not user:
            print("❌ User NOT found. Cannot migrate.")
            return

        # 2. Check/Create Default Panel for this user
        res_panel = await db.execute(select(Panel).where(Panel.user_id == user.id).limit(1))
        panel = res_panel.scalar_one_or_none()
        
        if not panel:
            print("➕ Creating default panel for user...")
            panel = Panel(
                user_id=user.id,
                name="나의 첫 번째 태양광 시설",
                location="위치 정보 없음 (자동 생성)",
                status="active"
            )
            db.add(panel)
            await db.commit()
            await db.refresh(panel)
            print(f"✅ Created Panel ID: {panel.id}")
        else:
            print(f"✅ Existing Panel found: ID={panel.id}")

        # 3. Update Analysis Sessions (PanelID 1 -> New Panel ID)
        print(f"🔄 Migrating Analysis Sessions from Panel ID 1 to {panel.id}...")
        res_sessions = await db.execute(
            update(AnalysisSession)
            .where(AnalysisSession.panel_id == 1)
            .values(panel_id=panel.id)
        )
        
        # 4. Update Detections (PanelID 1 -> New Panel ID)
        print(f"🔄 Migrating Detections from Panel ID 1 to {panel.id}...")
        res_detections = await db.execute(
            update(Detection)
            .where(Detection.panel_id == 1)
            .values(panel_id=panel.id)
        )
        
        await db.commit()
        print(f"✨ Migration completed successfully!")

if __name__ == "__main__":
    asyncio.run(link_data())
