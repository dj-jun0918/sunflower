import asyncio
import os
import sys
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select

# Add parent directory to sys.path
sys.path.append(os.getcwd())

try:
    from app.config import settings
    from app.models.user import User
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def seed_user():
    UID = "4xzw99BVSiZPBhubzaGt8w6oOwC2"
    EMAIL = "edu_164@iceu.kr"
    NAME = "Edu_164 Student"
    
    async with AsyncSessionLocal() as db:
        print(f"🧐 Checking for user {EMAIL}...")
        res = await db.execute(select(User).where(User.firebase_uid == UID))
        user = res.scalar_one_or_none()
        
        if not user:
            print("Creating new user...")
            user = User(
                firebase_uid=UID,
                email=EMAIL,
                display_name=NAME,
                is_active=True,
                last_login_at=datetime.utcnow()
            )
            db.add(user)
            await db.commit()
            print("✅ User created successfully!")
        else:
            print("✅ User already exists.")

if __name__ == "__main__":
    asyncio.run(seed_user())
