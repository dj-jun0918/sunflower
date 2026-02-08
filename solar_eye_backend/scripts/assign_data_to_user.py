"""
현재 로그인한 사용자에게 샘플 데이터를 할당하는 스크립트
"""
import asyncio
import sys

# 현재 앱에서 로그인한 사용자의 Firebase UID
# 로그에서 확인: user_id": "iSdXTIOG9EP4RzUmf0dqXPxePZI3"
CURRENT_USER_FIREBASE_UID = "iSdXTIOG9EP4RzUmf0dqXPxePZI3"

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, update
from app.config import settings
from app.models.user import User
from app.models.panel import Panel
from app.models.detection import Detection
from app.models.daily_report import DailyReport

engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def assign_data_to_current_user():
    async with AsyncSessionLocal() as db:
        # 1. 현재 사용자 찾기 또는 생성
        result = await db.execute(
            select(User).where(User.firebase_uid == CURRENT_USER_FIREBASE_UID)
        )
        user = result.scalar_one_or_none()
        
        if not user:
            print(f"❌ User with Firebase UID {CURRENT_USER_FIREBASE_UID} not found!")
            print("Please login to the app first to create the user.")
            return
        
        print(f"✅ Found user: {user.email} (ID: {user.id})")
        
        # 2. 기존 패널 중 user_id가 다른 것들을 현재 사용자에게 할당
        result = await db.execute(select(Panel).where(Panel.user_id != user.id))
        other_panels = result.scalars().all()
        
        if other_panels:
            print(f"📦 Reassigning {len(other_panels)} panels to current user...")
            for panel in other_panels:
                panel.user_id = user.id
                db.add(panel)
            await db.commit()
            print(f"✅ {len(other_panels)} panels reassigned!")
        else:
            print("ℹ️ No panels to reassign (already owned by current user or no panels exist)")
        
        # 3. 현재 사용자의 패널 확인
        result = await db.execute(select(Panel).where(Panel.user_id == user.id))
        user_panels = result.scalars().all()
        print(f"📊 Current user now owns {len(user_panels)} panels")
        
        for p in user_panels:
            print(f"  - Panel {p.id}: {p.name}")

if __name__ == "__main__":
    asyncio.run(assign_data_to_current_user())
