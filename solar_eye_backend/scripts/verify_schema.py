import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

# Add parent directory to sys.path
sys.path.append(os.getcwd())

try:
    from app.config import settings
except ImportError as e:
    print(f"Import error: {e}")
    sys.exit(1)

async def verify_schema():
    engine = create_async_engine(settings.get_database_url(), echo=False)
    
    print("--- Database Schema Verification ---")
    
    try:
        async with engine.connect() as conn:
            # 1. List all tables
            res = await conn.execute(text("SELECT table_name FROM information_schema.tables WHERE table_schema='public'"))
            tables = [r[0] for r in res]
            print(f"Found tables: {tables}")
            
            # 2. Check specific tables
            for table in ["users", "panels", "detections", "alembic_version"]:
                if table in tables:
                    try:
                        count_res = await conn.execute(text(f"SELECT count(*) FROM {table}"))
                        count = count_res.scalar()
                        print(f"✅ Table '{table}' exists. Row count: {count}")
                    except Exception as e:
                        print(f"❌ Table '{table}' exists but query failed: {e}")
                else:
                    print(f"❌ Table '{table}' MISSING!")
                    
    except Exception as e:
        print(f"Database connection failed: {e}")
    finally:
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(verify_schema())
