import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

sys.path.append(os.getcwd())
from app.config import settings

async def seed_student():
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
        print(f"User ID: {user_id}")
        
        # 2. Check if panels exist
        res = await conn.execute(text("SELECT count(*) FROM panels WHERE user_id = :uid"), {"uid": user_id})
        count = res.scalar()
        if count > 0:
            print(f"User already has {count} panels. Skipping panel seed.")
        else:
            print("Creating a test panel...")
            await conn.execute(text("""
                INSERT INTO panels (user_id, name, location, status, capacity_kw, panel_count, latitude, longitude, created_at)
                VALUES (:uid, :name, :loc, :status, :cap, :count, :lat, :lon, NOW())
            """), {
                "uid": user_id,
                "name": "춘천 테스트 발전소 A",
                "loc": "강원도 춘천시 동내면 거두리",
                "status": "active",
                "cap": 100.0,
                "count": 1,
                "lat": 37.8813,
                "lon": 127.7298
            })
            print("Panel created.")

    print("Success!")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(seed_student())
