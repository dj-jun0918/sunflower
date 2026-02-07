import asyncio
import sys
import uuid
from pathlib import Path
from io import BytesIO

# Force UTF-8
sys.stdout.reconfigure(encoding='utf-8')

sys.path.append(str(Path(__file__).parent.parent))

from fastapi import UploadFile
from app.services.analysis_service import AnalysisService
from app.db.session import async_session_factory
from app.models.panel import Panel
from sqlalchemy import select

async def debug():
    print("Debugging AnalysisService...")
    
    async with async_session_factory() as db:
        # Get Panel
        print("Fetching panel...")
        result = await db.execute(select(Panel).limit(1))
        panel = result.scalar_one_or_none()
        if not panel:
            print("No panel found")
            return
        print(f"Panel ID: {panel.id}")
        
        # Create Dummy File
        # We need a valid image for CV2 to not crash if analyze_image_bytes is called
        # Or at least expected to fail gracefully if image is bad
        # Let's create a minimal valid JPEG
        from PIL import Image
        img = Image.new('RGB', (100, 100), color = 'red')
        buf = BytesIO()
        img.save(buf, format='JPEG')
        buf.seek(0)
        
        file = UploadFile(filename="test_debug.jpg", file=buf)
        
        try:
            print("Calling process_analysis...")
            result = await AnalysisService.process_analysis(
                db=db,
                facility_id=panel.id,
                image_file=file,
                monitoring_type="cctv"
            )
            print("Success:", result)
        except Exception as e:
            print("Error:", e)
            with open("debug_error.txt", "w", encoding="utf-8") as f:
                f.write(str(e) + "\n")
                import traceback
                traceback.print_exc(file=f)

if __name__ == "__main__":
    asyncio.run(debug())
