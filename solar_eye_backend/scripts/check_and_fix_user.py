"""
사용자 및 패널 상태 확인
"""
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import select, update
from app.config import settings
from app.models.user import User
from app.models.panel import Panel

CURRENT_USER_FIREBASE_UID = "iSdXTIOG9EP4RzUmf0dqXPxePZI3"

engine = create_async_engine(settings.get_database_url())

async def check_and_fix():
    async with AsyncSession(engine) as db:
        # 모든 사용자 확인
        result = await db.execute(select(User))
        users = result.scalars().all()
        print("=== All Users ===")
        for u in users:
            print(f"  ID:{u.id} | UID:{u.firebase_uid[:20]}... | Email:{u.email}")
        
        # 현재 사용자 찾기
        result = await db.execute(
            select(User).where(User.firebase_uid == CURRENT_USER_FIREBASE_UID)
        )
        current_user = result.scalar_one_or_none()
        
        if not current_user:
            print(f"\n❌ Current user not found!")
            return
        
        print(f"\n=== Current User ===")
        print(f"  ID: {current_user.id}, Email: {current_user.email}")
        
        # 모든 패널 확인
        result = await db.execute(select(Panel))
        all_panels = result.scalars().all()
        print(f"\n=== All Panels ({len(all_panels)}) ===")
        for p in all_panels:
            print(f"  Panel {p.id}: user_id={p.user_id}, name={p.name}")
        
        # 패널 소유자 변경
        if all_panels:
            print(f"\n🔧 Reassigning all panels to user {current_user.id}...")
            await db.execute(
                update(Panel).values(user_id=current_user.id)
            )
            await db.commit()
            print("✅ Done!")
        
        # 확인
        result = await db.execute(select(Panel).where(Panel.user_id == current_user.id))
        user_panels = result.scalars().all()
        print(f"\n=== Current User Panels ({len(user_panels)}) ===")
        for p in user_panels:
            print(f"  Panel {p.id}: {p.name}")

if __name__ == "__main__":
    asyncio.run(check_and_fix())
