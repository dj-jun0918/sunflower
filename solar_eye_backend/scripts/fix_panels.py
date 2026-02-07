"""
간단한 사용자 패널 재할당 스크립트
"""
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import text
from app.config import settings

CURRENT_USER_FIREBASE_UID = "iSdXTIOG9EP4RzUmf0dqXPxePZI3"

engine = create_async_engine(settings.get_database_url())

async def fix():
    async with AsyncSession(engine) as db:
        # 모든 사용자 확인
        result = await db.execute(text("SELECT id, firebase_uid, email FROM users"))
        users = result.fetchall()
        print("=== All Users ===")
        current_user_id = None
        for u in users:
            print(f"  ID:{u[0]} | UID:{u[1][:20]}... | Email:{u[2]}")
            if u[1] == CURRENT_USER_FIREBASE_UID:
                current_user_id = u[0]
        
        if not current_user_id:
            print(f"\n❌ Current user not found!")
            return
        
        print(f"\n✅ Current user ID: {current_user_id}")
        
        # 모든 패널 확인
        result = await db.execute(text("SELECT id, user_id, name FROM panels"))
        panels = result.fetchall()
        print(f"\n=== All Panels ({len(panels)}) ===")
        for p in panels:
            print(f"  Panel {p[0]}: user_id={p[1]}, name={p[2]}")
        
        # 패널 소유자 변경
        if panels:
            print(f"\n🔧 Reassigning all panels to user {current_user_id}...")
            await db.execute(
                text(f"UPDATE panels SET user_id = {current_user_id}")
            )
            await db.commit()
            print("✅ Panels reassigned!")
        
        # 확인
        result = await db.execute(text(f"SELECT COUNT(*) FROM panels WHERE user_id = {current_user_id}"))
        count = result.scalar()
        print(f"\n📊 Current user now owns {count} panels")

if __name__ == "__main__":
    asyncio.run(fix())
