import asyncio
import sys
import os

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy import select
from app.db.session import async_session_factory
from app.models.analysis import AnalysisSession, AnalysisStatus, MonitoringType
from app.models.detection import Detection, DefectType
from app.models.panel import Panel, PanelStatus
from app.models.user import User

async def verify_schema():
    async with async_session_factory() as session:
        print("🔍 Checking Database Schema...")

        # 1. Get or Create a Test User and Panel
        result = await session.execute(select(User).limit(1))
        user = result.scalar_one_or_none()
        
        if not user:
            print("⚠️ No user found. Creating dummy user...")
            user = User(
                email="test@example.com", 
                firebase_uid="test_uid",
                full_name="Test User"
            )
            session.add(user)
            await session.commit()
            await session.refresh(user)

        result = await session.execute(select(Panel).filter_by(user_id=user.id).limit(1))
        panel = result.scalar_one_or_none()

        if not panel:
            print("⚠️ No panel found. Creating dummy panel...")
            panel = Panel(
                user_id=user.id,
                name="Test Panel",
                status=PanelStatus.ACTIVE.value
            )
            session.add(panel)
            await session.commit()
            await session.refresh(panel)
        
        print(f"✅ Using Panel ID: {panel.id}")

        # 2. Create AnalysisSession
        print("🧪 Creating AnalysisSession...")
        analysis = AnalysisSession(
            panel_id=panel.id,
            type=MonitoringType.CCTV,
            status=AnalysisStatus.PROCESSING,
            original_image_url="http://example.com/image.jpg"
        )
        session.add(analysis)
        await session.flush() # Flush to get ID
        print(f"✅ AnalysisSession Created. ID: {analysis.id}")

        # 3. Create Linked Detection
        print("🧪 Creating Linked Detection...")
        detection = Detection(
            panel_id=panel.id,
            analysis_session_id=analysis.id,
            defect_type=DefectType.DEFECT,
            confidence=0.95,
            bbox_x=10, bbox_y=10, bbox_width=50, bbox_height=50,
            detected_at=analysis.created_at
        )
        session.add(detection)
        await session.commit()
        print(f"✅ Detection Created. ID: {detection.id}")

        # 4. Verify Relationship
        print("🔍 Verifying Relationship...")
        await session.refresh(analysis)
        
        # Access relationship (will trigger lazy load if not careful, but here we just check DB state)
        # Re-query detection to check FK
        result = await session.execute(select(Detection).where(Detection.id == detection.id))
        saved_detection = result.scalar_one()
        
        if saved_detection.analysis_session_id == analysis.id:
             print("✅ Relationship Verified: Detection is linked to AnalysisSession!")
        else:
             print("❌ Relationship Logic Failed!")

        # Clean up (optional, but good for repetitive testing)
        # await session.delete(analysis) 
        # await session.delete(detection)
        # await session.commit()
        
if __name__ == "__main__":
    asyncio.run(verify_schema())
