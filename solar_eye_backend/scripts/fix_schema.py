import asyncio
import os
import sys
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

sys.path.append(os.getcwd())
try:
    from app.config import settings
except ImportError:
    print("Could not import app.config. Ensure you are in the project root.")
    sys.exit(1)

async def fix_schema():
    engine = create_async_engine(settings.get_database_url())
    
    async with engine.begin() as conn:
        # Tables and columns check
        table_columns = {
            "panels": {
                "thumbnail_url": "TEXT",
                "created_at": "TIMESTAMP WITH TIME ZONE DEFAULT NOW()",
                "updated_at": "TIMESTAMP WITH TIME ZONE DEFAULT NOW()",
                "capacity_kw": "FLOAT",
                "panel_count": "INTEGER",
                "grid_nx": "INTEGER",
                "grid_ny": "INTEGER",
            },
            "detections": {
                "defect_type": "VARCHAR(50) DEFAULT 'normal' NOT NULL",
                "defect_subtype": "VARCHAR(50)",
                "frame_number": "INTEGER",
                "area_percentage": "FLOAT",
                "mask": "TEXT",
                "detected_at": "TIMESTAMP WITH TIME ZONE DEFAULT NOW()",
            },
            "users": {
                "photo_url": "VARCHAR",
                "provider": "VARCHAR",
                "notification_enabled": "BOOLEAN DEFAULT TRUE",
                "fcm_token": "VARCHAR",
                "last_login_at": "TIMESTAMP",
                "created_at": "TIMESTAMP WITH TIME ZONE DEFAULT NOW()",
            }
        }
        
        for table, columns in table_columns.items():
            print(f"Checking table '{table}'...")
            res = await conn.execute(text(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table}'"))
            existing_columns = [r[0] for r in res]
            
            for col_name, col_type in columns.items():
                if col_name not in existing_columns:
                    print(f"  Adding column {col_name} to {table}...")
                    try:
                        await conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {col_name} {col_type}"))
                    except Exception as e:
                        print(f"  FAILED to add {col_name}: {e}")
                else:
                    print(f"  Column {col_name} already exists.")

    print("\n--- Final Schema Check ---")
    async with engine.connect() as conn:
        for table in table_columns.keys():
            res = await conn.execute(text(f"SELECT column_name FROM information_schema.columns WHERE table_name = '{table}'"))
            print(f"{table}: {[r[0] for r in res]}")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(fix_schema())
