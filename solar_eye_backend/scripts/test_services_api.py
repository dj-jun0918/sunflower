import sys
import os
import io
from pathlib import Path

# Force UTF-8 for Windows console/files
sys.stdout.reconfigure(encoding='utf-8')

# Add project root to sys.path
sys.path.append(str(Path(__file__).parent.parent))

from fastapi.testclient import TestClient
from app.main import app
from app.api.deps import get_current_user
from app.models.user import User

# Mock User for Auth
async def override_get_current_user():
    return User(id=1, email="test@example.com", firebase_uid="test_uid", display_name="Test User")

app.dependency_overrides[get_current_user] = override_get_current_user

client = TestClient(app)

def test_services_api():
    print("=" * 60)
    print("Testing Services API Integration (Mock)")
    print("=" * 60)

    # 1. Get Cleaning Companies
    print("📡 GET /api/v1/services/cleaning/companies ...")
    response = client.get("/api/v1/services/cleaning/companies")
    
    if response.status_code != 200:
        print(f"❌ Failed: {response.status_code}")
        print(response.json())
        return

    data = response.json()
    items = data.get('data', [])
    print(f"✅ Cleaning Companies: {len(items)}")
    for item in items:
        print(f"   - {item['name']} ({item['rating']})")

    # 2. Get Repair Companies
    print("\n📡 GET /api/v1/services/repair/companies ...")
    response = client.get("/api/v1/services/repair/companies")
    
    if response.status_code != 200:
        print(f"❌ Failed: {response.status_code}")
        print(response.json())
        return

    data = response.json()
    items = data.get('data', [])
    print(f"✅ Repair Companies: {len(items)}")
    for item in items:
        print(f"   - {item['name']} ({item['rating']})")

    # 3. Request Cleaning Service
    print("\n📡 POST /api/v1/services/cleaning/request ...")
    payload = {
        "facility_id": 1,
        "company_id": "clean-co-1",
        "request_details": "Please clean ASAP"
    }
    response = client.post("/api/v1/services/cleaning/request", json=payload)
    
    if response.status_code != 200:
        print(f"❌ Failed: {response.status_code}")
        print(response.json())
        return
        
    data = response.json()
    result = data.get('data', {})
    print(f"✅ Request Success!")
    print(f"   - Request ID: {result.get('request_id')}")
    print(f"   - Status: {result.get('status')}")
    print(f"   - Company: {result.get('company_name')}")

if __name__ == "__main__":
    test_services_api()
