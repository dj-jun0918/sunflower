import asyncio
import os
import sys
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select

# Add parent directory to sys.path
sys.path.append(os.getcwd())

try:
    from app.config import settings
    from app.models.user import User
    from app.models.panel import Panel
    from app.models.analysis import AnalysisSession
except ImportError as e:
    with open("db_check_result.txt", "w", encoding="utf-8") as f:
        f.write(f"Import error: {e}")
    sys.exit(1)

engine = create_async_engine(settings.get_database_url(), echo=True)
AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def check_db():
    TARGET_EMAIL = "edu_164@iceu.kr"
    output = []
    
    async with AsyncSessionLocal() as db:
        output.append(f"🧐 Checking DB for {TARGET_EMAIL}...")
        
        # 1. User
        res_user = await db.execute(select(User).where(User.email == TARGET_EMAIL))
        user = res_user.scalar_one_or_none()
        if user:
            output.append(f"User found: ID={user.id}, Email={user.email}")
            
            # 2. Panels for this user
            res_panels = await db.execute(select(Panel).where(Panel.user_id == user.id))
            panels = res_panels.scalars().all()
            output.append(f"Total Panels for User: {len(panels)}")
            for p in panels:
                output.append(f" - Panel ID={p.id}, Name={p.name}")
        else:
            output.append("User NOT found in DB.")

        # 3. All Analysis Sessions
        res_sessions = await db.execute(select(AnalysisSession).order_by(AnalysisSession.created_at.desc()).limit(10))
        sessions = res_sessions.scalars().all()
        output.append(f"Recent Analysis Sessions (Global): {len(sessions)}")
        for s in sessions:
            output.append(f" - Session ID={s.id}, PanelID={s.panel_id}, Status={s.status}, CreatedAt={s.created_at}")

        # 4. Any Analysis Sessions with PanelID=1
        res_p1 = await db.execute(select(AnalysisSession).where(AnalysisSession.panel_id == 1))
        p1_sessions = res_p1.scalars().all()
        output.append(f"Analysis Sessions for Panel ID 1: {len(p1_sessions)}")

    with open("db_check_result.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(output))

if __name__ == "__main__":
    asyncio.run(check_db())
