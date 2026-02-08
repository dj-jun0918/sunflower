import sys
import os
import cv2
import numpy as np
from pathlib import Path
from ultralytics import YOLO

def inspect_model(model_path):
    print(f"--- Inspecting Model: {model_path} ---")
    if not os.path.exists(model_path):
        print("❌ Model not found")
        return

    try:
        model = YOLO(model_path)
        print(f"✅ Model loaded. Type: {type(model)}")
        print(f"   Names: {model.names}")
        print(f"   Task: {model.task}")
        # print(f"   Overrides: {model.overrides}")
        
        return model
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        return None

def test_multiple_images(model, image_dir):
    print(f"\n--- Testing Multiple Images in {image_dir} ---")
    image_paths = list(Path(image_dir).rglob("*.jpg")) + list(Path(image_dir).rglob("*.png"))
    
    if not image_paths:
        print("❌ No images found")
        return

    # Take first 5 images
    for img_path in image_paths[:10]:
        print(f"\nTesting: {img_path.name}")
        image = cv2.imread(str(img_path))
        if image is None:
            print("  ❌ Failed to load image")
            continue
            
        # Convert to RGB as good practice for YOLOv8
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        results = model.predict(image_rgb, conf=0.1, imgsz=1024, verbose=False)
        
        found = 0
        for r in results:
            found += len(r.boxes)
            if len(r.boxes) > 0:
                for box in r.boxes:
                    print(f"    - Found: {model.names[int(box.cls[0])]} @ {box.conf[0]:.4f}")
        
        if found == 0:
            print("  ⚠️ 0 detections found even at conf 0.1")
        else:
            print(f"  ✅ Total Detections: {found}")

if __name__ == "__main__":
    cctv_model_path = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\app\ai\models\yolo26m40000_weights_best.pt"
    upload_dir = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\static\uploads"
    
    m = inspect_model(cctv_model_path)
    if m:
        test_multiple_images(m, upload_dir)
