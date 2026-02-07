import asyncio
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.config import settings
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text

async def add_column():
    print("Migrating DB: Adding 'mask' column to 'detections' table...")
    engine = create_async_engine(settings.get_database_url(), echo=True)
    
    async with engine.begin() as conn:
        try:
            await conn.execute(text("ALTER TABLE detections ADD COLUMN IF NOT EXISTS mask TEXT;"))
            print("✅ Successfully added 'mask' column.")
        except Exception as e:
            print(f"❌ Migration failed: {e}")
            
    await engine.dispose()

if __name__ == "__main__":
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    asyncio.run(add_column())
