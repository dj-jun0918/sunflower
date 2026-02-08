"""
Debug Script for YOLO Only (Lightweight)
"""
import sys
import os
import cv2
import numpy as np
import logging
from pathlib import Path

# Add project root to path
sys.path.append(str(Path(__file__).parent.parent))

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("debug_yolo")

from app.ai.yolo_detector import YOLODetector

def debug_yolo(image_path):
    print(f"🔍 Checking YOLO on: {image_path}")
    
    if not os.path.exists(image_path):
        print("❌ Image file not found!")
        return

    model_path = Path("app/ai/models/yolo26m40000_weights_best.pt")
    if not model_path.exists():
        print(f"❌ Model not found at {model_path}")
        return

    print("1. Loading YOLO Model...")
    try:
        detector = YOLODetector(
            model_path=str(model_path),
            conf_threshold=0.25, # Lower threshold to see if it detects ANYTHING
            iou_threshold=0.45
        )
        print("✅ Detector loaded.")
    except Exception as e:
        print(f"❌ Detector load failed: {e}")
        return

    # 2. Image Load
    image = cv2.imread(image_path)
    if image is None:
        print("❌ Failed to load image.")
        return
    print(f"✅ Image loaded. Shape: {image.shape}")

    # 3. Direct Model Call (Bypass Wrapper)
    print("\n--- Running Raw Model Inference ---")
    results = detector.model(image, conf=0.01, verbose=True) # Ultra low conf
    
    for r in results:
        print(f"   Raw Boxes Sent: {len(r.boxes)}")
        for box in r.boxes:
             print(f"     -> Conf: {box.conf.item():.4f}, Cls: {box.cls.item()}, xyxy: {box.xyxy.tolist()}")

    # 3. Detection via Wrapper
    print("\n--- Running Wrapper Detection ---")
    detections = detector.detect(image)
    print(f"   Detections Found: {len(detections)}")

if __name__ == "__main__":
    target_image = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\static\uploads\2026\02\832fe41e-c0d6-4245-815f-f3aead701073.jpg"
    # Ensure correct working directory when running
    debug_yolo(target_image)
