import asyncio
import sys
import os
import traceback

print(f"Current working directory: {os.getcwd()}")
print(f"Python path: {sys.path}")

try:
    from app.config import settings
    print(f"Import successful: app.config (DB URL: {settings.database_url})")
except ImportError:
    print("Import failed!")
    traceback.print_exc()
    sys.exit(1)

from datetime import datetime, timedelta
import random

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, delete

from app.models.user import User
# ... rest of imports
from app.models.panel import Panel
from app.models.detection import Detection
from app.models.daily_report import DailyReport
# Database connection
engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def seed_data():
    async with AsyncSessionLocal() as db:
        print("🌱 Seeding data for 'Chuncheon No. 1 Power Plant' (100kW)...")

        # 1. Create or Get User (Target User from the logs)
        TARGET_EMAIL = "edu_164@iceu.kr"
        TARGET_UID = "4xzw99BVSiZPBhubzaGt8w6oOwC2" # From the user's JWT log

        result = await db.execute(select(User).where(User.email == TARGET_EMAIL))
        user = result.scalar_one_or_none()
        
        if not user:
            print(f"Creating user {TARGET_EMAIL}...")
            user = User(
                email=TARGET_EMAIL,
                firebase_uid=TARGET_UID, 
                display_name="테스트 사용자",
                is_active=True,
                provider="google",
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
        else:
            print(f"User found: {user.email} (ID: {user.id})")
            # Ensure user has name
            if not user.display_name:
                user.display_name = "테스트 사용자"
                db.add(user)
                await db.commit()

        # 3. Create Panels (100kW Plant -> Approx 4 zones/arrays for visualization)
        # Chuncheon Coordinates: 37.8813, 127.7298
        print("Creating panels...")
        
        # Check if panels exist
        result = await db.execute(select(Panel).where(Panel.user_id == user.id))
        existing_panels = result.scalars().all()
        
        panels = []
        if not existing_panels:
            zones = ["A구역", "B구역", "C구역", "D구역"] # 4 zones, 25kW each
            for i, zone in enumerate(zones):
                panel = Panel(
                    user_id=user.id,
                    name=f"춘천 제 1 발전소 {zone}",
                    location="강원도 춘천시 동내면 거두리 123",
                    description=f"한화 Q.PEAK DUO 패널 적용 ({zone})",
                    latitude=37.8813 + (i * 0.0001), # Slightly offset
                    longitude=127.7298 + (i * 0.0001),
                    capacity_kw=25.0, # 25kW per zone * 4 = 100kW
                    status="active",
                    grid_nx=68, # Chuncheon grid X
                    grid_ny=123, # Chuncheon grid Y
                )
                db.add(panel)
                panels.append(panel)
            await db.commit()
            # Refresh to get IDs
            for p in panels:
                await db.refresh(p)
        else:
            panels = existing_panels
            print(f"Using {len(panels)} existing panels.")

        # 4. Create Recent Detections (Today)
        print("Creating detections...")
        today = datetime.now()
        
        # Recent detection in Zone C (Panel index 2) - Soiling
        d1 = Detection(
            panel_id=panels[2].id,
            detected_at=today - timedelta(hours=2),
            defect_type="soiling",
            defect_subtype="dust",
            confidence=0.85,
            snapshot_url="https://via.placeholder.com/600x400?text=Soiling+Detection",
            bbox_x=100, bbox_y=150, bbox_width=200, bbox_height=200,
        )
        db.add(d1)

        # Recent detection in Zone D (Panel index 3) - Crack (Critical)
        d2 = Detection(
            panel_id=panels[3].id,
            detected_at=today - timedelta(hours=1),
            defect_type="defect",
            defect_subtype="crack",
            confidence=0.92,
            snapshot_url="https://via.placeholder.com/600x400?text=Crack+Detection",
            bbox_x=50, bbox_y=50, bbox_width=100, bbox_height=300,
        )
        db.add(d2)

        await db.commit()

        # 5. Create Daily Reports (Past 7 days)
        print("Creating daily reports...")
        
        for i in range(7):
            date_val = today - timedelta(days=i)
            date_only = date_val.date()
            
            # Create a report for EACH panel
            for panel in panels:
                # Check if report already exists
                result = await db.execute(
                    select(DailyReport)
                    .where(DailyReport.panel_id == panel.id)
                    .where(DailyReport.report_date == date_only)
                )
                if result.scalar_one_or_none():
                    continue

                # Simulate daily generation (Efficiency factor)
                # Max generation per panel (25kW * 4h = 100kWh)
                weather_factor = random.uniform(0.6, 1.0) 
                daily_gen = 100.0 * weather_factor 
                
                report = DailyReport(
                    panel_id=panel.id,
                    report_date=date_only,
                    total_detections=random.randint(0, 2),
                    total_defects=random.randint(0, 1),
                    total_soiling=random.randint(0, 1),
                    avg_soiling_area=random.uniform(0, 5.0) if random.random() > 0.7 else 0.0,
                    max_soiling_area=0.0,
                    estimated_loss_kwh=daily_gen * 0.05 if random.random() > 0.8 else 0.0,
                    estimated_loss_krw=0.0,
                    cleaning_recommended=random.choice([True, False]) if random.random() > 0.9 else False,
                    weather_summary="맑음" if weather_factor > 0.8 else "구름 많음",
                    had_rain=False,
                    ai_solution_type="good" if weather_factor > 0.8 else "caution",
                    ai_solution_title="발전 효율 양호" if weather_factor > 0.8 else "효율 저하 감지",
                    ai_solution_content="특이사항 없이 양호한 발전 상태를 보이고 있습니다." if weather_factor > 0.8 else "구름으로 인한 발전량 저하가 예상됩니다.",
                )
                
                # Update loss KRW based on loss kWh
                if report.estimated_loss_kwh:
                    report.estimated_loss_krw = report.estimated_loss_kwh * 150 # 150 KRW/kWh

                db.add(report)
        
        await db.commit()

        print("✅ Seeding completed with Daily Reports!")

if __name__ == "__main__":
    asyncio.run(seed_data())
