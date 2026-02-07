"""
전체 사용자 목록 출력
"""
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import text
from app.config import settings

CURRENT_USER_FIREBASE_UID = "iSdXTIOG9EP4RzUmf0dqXPxePZI3"

engine = create_async_engine(settings.get_database_url())

async def show_users():
    async with AsyncSession(engine) as db:
        result = await db.execute(text("SELECT id, firebase_uid, email FROM users ORDER BY id"))
        users = result.fetchall()
        print("ALL USERS:")
        for u in users:
            marker = " <-- CURRENT" if u[1] == CURRENT_USER_FIREBASE_UID else ""
            print(f"  {u[0]}: {u[2]} ({u[1][:12]}...){marker}")
        
        result = await db.execute(text("SELECT user_id, COUNT(*) as cnt FROM panels GROUP BY user_id"))
        panel_counts = result.fetchall()
        print("\nPANELS BY USER:")
        for pc in panel_counts:
            print(f"  User {pc[0]}: {pc[1]} panels")

if __name__ == "__main__":
    asyncio.run(show_users())
