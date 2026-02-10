import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

sys.path.append(os.getcwd())
try:
    from app.config import settings
except ImportError:
    print("Could not import app.config.")
    sys.exit(1)

async def cleanup_panels():
    engine = create_async_engine(settings.get_database_url())
    
    TARGET_EMAIL = "edu_164@iceu.kr"
    
    async with engine.begin() as conn:
        # 1. Get user ID
        res = await conn.execute(text("SELECT id FROM users WHERE email = :email"), {"email": TARGET_EMAIL})
        user_row = res.fetchone()
        if not user_row:
            print(f"User {TARGET_EMAIL} not found!")
            return
        user_id = user_row[0]
        print(f"Deleting panels for User ID: {user_id}...")
        
        # 2. Delete detections first (cascading might handle it, but better safe)
        await conn.execute(text("""
            DELETE FROM detections WHERE panel_id IN (SELECT id FROM panels WHERE user_id = :uid)
        """), {"uid": user_id})
        
        # 3. Delete panels
        res = await conn.execute(text("DELETE FROM panels WHERE user_id = :uid"), {"uid": user_id})
        print(f"Deleted {res.rowcount} panels.")

    print("Cleanup Success!")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(cleanup_panels())
