import asyncio
from sqlalchemy import select, update
from app.db.session import engine
from app.models.user import User
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import AsyncSession

AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def fix_uid():
    async with AsyncSessionLocal() as db:
        print("Finding admin user...")
        result = await db.execute(select(User).where(User.email == "admin@solareye.com"))
        user = result.scalar_one_or_none()
        
        if user:
            print(f"Updating UID for {user.email}...")
            # Update UID to the one causing 401s
            await db.execute(
                update(User)
                .where(User.id == user.id)
                .values(firebase_uid="iSdXTIOG9EP4RzUmf0dqXPxePZI3")
            )
            await db.commit()
            print("✅ UID updated successfully to 'iSdXTIOG9EP4RzUmf0dqXPxePZI3'")
        else:
            print("❌ Admin user not found!")

if __name__ == "__main__":
    asyncio.run(fix_uid())
