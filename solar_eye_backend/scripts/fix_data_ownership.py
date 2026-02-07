import asyncio
import sys
import os
import traceback

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from app.config import settings
    from app.core.firebase import init_firebase
    from firebase_admin import auth
except ImportError:
    print("Import failed!")
    traceback.print_exc()
    sys.exit(1)

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, update
from app.models.user import User
from app.models.panel import Panel

# Database connection
engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

TARGET_EMAIL = "edu_164@iceu.kr"

async def fix_ownership():
    print("Fixing Data Ownership...")
    
    # 1. Initialize Firebase to get real UID
    firebase_app = init_firebase()
    if not firebase_app:
        print("Firebase init failed. Check .env and credentials file.")
        return

    try:
        user_record = auth.get_user_by_email(TARGET_EMAIL)
        real_uid = user_record.uid
        print(f"Found Firebase User: {TARGET_EMAIL} -> UID: {real_uid}")
    except Exception as e:
        print(f"Failed to find user in Firebase: {e}")
        return

    async with AsyncSessionLocal() as db:
        # 2. Find existing 'admin' user or ANY user who owns the panels
        # The seed data created 'admin@solareye.com' with fake UID
        stmt = select(User).where(User.email == "admin@solareye.com")
        result = await db.execute(stmt)
        admin_user = result.scalar_one_or_none()

        if admin_user:
            print(f"Found existing admin user (ID: {admin_user.id}) with Fake UID: {admin_user.firebase_uid}")
            
            # Update admin user to be the real user
            admin_user.email = TARGET_EMAIL
            admin_user.firebase_uid = real_uid
            admin_user.display_name = "User (Fixed)"
            
            db.add(admin_user)
            await db.commit()
            print(f"Updated DB User to matched {TARGET_EMAIL} / {real_uid}")
            
            # Verify panels
            panel_stmt = select(Panel).where(Panel.user_id == admin_user.id)
            panels = (await db.execute(panel_stmt)).scalars().all()
            print(f"Associated {len(panels)} panels to this user.")
            
        else:
            print("admin@solareye.com not found. Checking if target user already exists...")
            
            # Check if target user exists
            stmt = select(User).where(User.firebase_uid == real_uid)
            target_user = (await db.execute(stmt)).scalar_one_or_none()
            
            if target_user:
                 print(f"User {TARGET_EMAIL} already exists in DB. ID: {target_user.id}")
                 # Check panels
                 panel_stmt = select(Panel).where(Panel.user_id == target_user.id)
                 panels = (await db.execute(panel_stmt)).scalars().all()
                 print(f"User has {len(panels)} panels.")
            else:
                print("No suitable user found to patch. Please run seed_data.py first.")

if __name__ == "__main__":
    try:
        if sys.platform == 'win32':
            asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
        asyncio.run(fix_ownership())
    except Exception:
        with open("scripts/error.log", "w", encoding="utf-8") as f:
            traceback.print_exc(file=f)

