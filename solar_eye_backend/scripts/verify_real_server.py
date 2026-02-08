import sys
import os
import io
import time
import httpx
from PIL import Image

# Force UTF-8
sys.stdout.reconfigure(encoding='utf-8')

BASE_URL = "http://127.0.0.1:8123"

def create_dummy_image():
    img = Image.new('RGB', (640, 640), color = (73, 109, 137))
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='JPEG')
    img_byte_arr.seek(0)
    return img_byte_arr

def verify_monitoring():
    print("=" * 60)
    print("Verifying Monitoring API against Real Server")
    print("=" * 60)

    try:
        # Wait for server to be up
        for i in range(10):
            try:
                resp = httpx.get(f"{BASE_URL}/health")
                if resp.status_code == 200:
                    print("✅ Server is UP")
                    break
            except httpx.ConnectError:
                pass
            time.sleep(1)
        else:
            print("❌ Server failed to start")
            return

        # 1. Get Panels
        print("📡 GET /api/v1/panels ...")
        resp = httpx.get(f"{BASE_URL}/api/v1/panels")
        if resp.status_code != 200:
            print(f"❌ Failed to get panels: {resp.status_code} {resp.text}")
            return
        
        data = resp.json()
        items = data.get('data', [])
        if not items:
            print("❌ No panels found. Cannot proceed.")
            return
        
        panel_id = items[0]['id']
        print(f"✅ Found Panel ID: {panel_id}")

        # 2. Upload Image
        img_bytes = create_dummy_image()
        files = {'image': ('test.jpg', img_bytes.getvalue(), 'image/jpeg')}
        
        print(f"📡 POST /api/v1/monitoring/{panel_id}/cctv ...")
        resp = httpx.post(f"{BASE_URL}/api/v1/monitoring/{panel_id}/cctv", files=files)
        
        if resp.status_code != 202:
            print(f"❌ Upload Failed: {resp.status_code} {resp.text}")
            return
            
        data = resp.json()
        analysis_id = data['id']
        print(f"✅ Upload Success! Analysis ID: {analysis_id}")

        # 3. Get Result
        print(f"📡 GET /api/v1/monitoring/results/{analysis_id} ...")
        resp = httpx.get(f"{BASE_URL}/api/v1/monitoring/results/{analysis_id}")
        
        if resp.status_code != 200:
            print(f"❌ Get Result Failed: {resp.status_code} {resp.text}")
            return
        
        result = resp.json()
        print(f"✅ Result Retrieved! Status: {result['status']}")
        print(f"   Detections: {len(result.get('detections', []))}")

        # 4. Get History
        print(f"📡 GET /api/v1/monitoring/history/{panel_id} ...")
        resp = httpx.get(f"{BASE_URL}/api/v1/monitoring/history/{panel_id}")

        if resp.status_code != 200:
            print(f"❌ Get History Failed: {resp.status_code} {resp.text}")
            return
        
        history = resp.json()
        print(f"✅ History Retrieved! Count: {len(history)}")
        
        if any(h['id'] == analysis_id for h in history):
            print("✅ Verification Complete: New session found in history.")
        else:
            print("❌ Verification Failed: Session not found in history.")

    except Exception as e:
        print(f"❌ Exception during verification: {e}")

if __name__ == "__main__":
    verify_monitoring()
