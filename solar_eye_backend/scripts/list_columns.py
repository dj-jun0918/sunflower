import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

sys.path.append(os.getcwd())
from app.config import settings

async def list_columns():
    engine = create_async_engine(settings.get_database_url())
    async with engine.connect() as conn:
        res = await conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'detections'"))
        columns = [r[0] for r in res]
        print(f"Columns in 'detections': {columns}")
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(list_columns())
