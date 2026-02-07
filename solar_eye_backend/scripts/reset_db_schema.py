import asyncio
from app.db.base import Base
from app.db.session import engine
from sqlalchemy import text

async def reset_db():
    async with engine.begin() as conn:
        # Disable foreign key checks to allow dropping tables in any order (Postgres)
        # Actually in Postgres we can use CASCADE
        await conn.execute(text("DROP SCHEMA public CASCADE;"))
        await conn.execute(text("CREATE SCHEMA public;"))
        print("Database schema 'public' has been reset.")

if __name__ == "__main__":
    asyncio.run(reset_db())
