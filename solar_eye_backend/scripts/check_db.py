import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy import text
from app.config import settings

async def check_db():
    engine = create_async_engine(settings.get_database_url())
    async with AsyncSession(engine) as session:
        # Check users
        result = await session.execute(text('SELECT COUNT(*) FROM users'))
        print(f"Users count: {result.scalar()}")
        # Check panels
        result = await session.execute(text('SELECT COUNT(*) FROM panels'))
        print(f"Panels count: {result.scalar()}")
        # Check detections
        result = await session.execute(text('SELECT COUNT(*) FROM detections'))
        print(f"Detections count: {result.scalar()}")
        # Check daily_reports
        result = await session.execute(text('SELECT COUNT(*) FROM daily_reports'))
        print(f"Daily reports count: {result.scalar()}")

if __name__ == "__main__":
    asyncio.run(check_db())
