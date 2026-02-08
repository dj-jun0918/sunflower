import sys
import os
import io
from pathlib import Path

# Force UTF-8 for Windows console/files
sys.stdout.reconfigure(encoding='utf-8')

# Add project root to sys.path
sys.path.append(str(Path(__file__).parent.parent))

from fastapi.testclient import TestClient
from PIL import Image

from app.main import app
from app.api.deps import get_current_user
from app.models.user import User

# Mock User for Auth
async def override_get_current_user():
    return User(id=1, email="test@example.com", firebase_uid="test_uid", display_name="Test User")

app.dependency_overrides[get_current_user] = override_get_current_user

client = TestClient(app)

def create_dummy_image():
    # Create a simple 640x640 RGB image
    img = Image.new('RGB', (640, 640), color = (73, 109, 137))
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='JPEG')
    img_byte_arr.seek(0)
    return img_byte_arr

def test_monitoring_api():
    print("=" * 60)
    print("Testing Monitoring API Integration (with Auth Mock)")
    print("=" * 60)

    # 1. Get List of Panels to find a valid ID
    print("📡 Sending GET /api/v1/panels ...")
    response = client.get("/api/v1/panels")
    
    if response.status_code != 200:
        print(f"❌ Get Panels Failed: {response.status_code}")
        print(response.json())
        return

    data = response.json()
    items = data.get('data', [])
    if not items:
        print("❌ No panels found for Test User (ID=1). Cannot proceed.")
        return

    panel_id = items[0]['id']
    print(f"✅ Found Panel ID: {panel_id}")

    # 2. Test Image Upload (CCTV)
    img_bytes = create_dummy_image()
    files = {'image': ('test_image.jpg', img_bytes, 'image/jpeg')}
    
    print(f"📡 Sending POST /api/v1/monitoring/{panel_id}/cctv ...")
    response = client.post(f"/api/v1/monitoring/{panel_id}/cctv", files=files)
    
    if response.status_code != 202:
        print(f"❌ Upload Failed: {response.status_code}")
        print(response.json())
        return

    data = response.json()
    analysis_id = data['id']
    print(f"✅ Upload Success! Analysis ID: {analysis_id}")
    print(f"   Status: {data['status']}")

    # 3. Test Get Result
    print(f"📡 Sending GET /api/v1/monitoring/results/{analysis_id} ...")
    response = client.get(f"/api/v1/monitoring/results/{analysis_id}")
    
    if response.status_code != 200:
        print(f"❌ Get Result Failed: {response.status_code}")
        print(response.json())
        return

    result_data = response.json()
    print(f"✅ Result Retrieved!")
    print(f"   Status: {result_data['status']}")
    print(f"   Detections: {len(result_data.get('detections', []))}")

    # 4. Test Get History
    print(f"📡 Sending GET /api/v1/monitoring/history/{panel_id} ...")
    response = client.get(f"/api/v1/monitoring/history/{panel_id}")
    
    if response.status_code != 200:
        print(f"❌ Get History Failed: {response.status_code}")
        print(response.json())
        return

    history_data = response.json()
    print(f"✅ History Retrieved! Count: {len(history_data)}")
    
    # Check if our new session is in history
    found = any(s['id'] == analysis_id for s in history_data)
    if found:
        print("✅ Correctly found the new session in history.")
    else:
        print("❌ New session NOT found in history.")

if __name__ == "__main__":
    test_monitoring_api()
