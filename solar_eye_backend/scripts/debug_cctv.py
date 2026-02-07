"""
Debug Script for CCTV Pipeline
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
logger = logging.getLogger("debug_cctv")

from app.ai.pipeline import get_pipeline

def debug_cctv(image_path):
    print(f"🔍 Debugging Image: {image_path}")
    
    if not os.path.exists(image_path):
        print("❌ Image file not found!")
        return

    # 1. Pipeline Initialization
    print("\n--- 1. Pipeline Initialization ---")
    try:
        pipeline = get_pipeline()
        print("✅ Pipeline instance obtained.")
        
        print(f"   CCTV Detector: {pipeline.cctv_detector}")
        print(f"   Enhancer: {pipeline.enhancer}")
        print(f"   SegClassifier: {pipeline.seg_classifier}")
        
        if not pipeline.enhancer or not pipeline.seg_classifier:
            print("❌ Critical: Enhancer or SegClassifier failed to load!")
            return
            
    except Exception as e:
        print(f"❌ Pipeline Init Failed: {e}")
        return

    # 2. Image Load
    image = cv2.imread(image_path)
    if image is None:
        print("❌ Failed to load image with cv2.")
        return
    print(f"✅ Image loaded. Shape: {image.shape}")

    # 3. Detection (YOLO)
    print("\n--- 3. Running YOLO Detection ---")
    detections = pipeline.cctv_detector.detect(image)
    print(f"   Detections Found: {len(detections)}")
    for i, d in enumerate(detections):
        print(f"   [{i}] Conf: {d.confidence:.4f}, Box: {d.bbox}, Class: {d.class_name}")

    if not detections:
        print("⚠️ No detections. Stopping debug.")
        return

    # 4. Cropping & Filtering
    print("\n--- 4. Cropping & Filtering ---")
    crops = []
    valid_indices = []
    for i, detection in enumerate(detections):
        cropped = pipeline._crop_panel(image, detection.bbox)
        print(f"   [{i}] Crop Shape: {cropped.shape}")
        if cropped.shape[0] >= 10 and cropped.shape[1] >= 10:
            crops.append(cropped)
            valid_indices.append(i)
        else:
            print(f"   [{i}] ⚠️ Skipped (too small)")

    print(f"   Valid Crops: {len(crops)}")
    if not crops:
        return

    # 5. Enhancement (Real-ESRGAN)
    print("\n--- 5. Running Real-ESRGAN Enhancement ---")
    enhanced_crops = []
    for i, crop in enumerate(crops):
        try:
            print(f"   Enhancing Crop {i} ({crop.shape})...")
            enhanced = pipeline.enhancer.enhance(crop)
            print(f"     -> Result Shape: {enhanced.shape}")
            enhanced_crops.append(enhanced)
        except Exception as e:
            print(f"❌ Enhancement Failed for {i}: {e}")
            enhanced_crops.append(crop)

    # 6. Segmentation (SegFormer)
    print("\n--- 6. Running SegFormer Classification ---")
    try:
        seg_results = pipeline.seg_classifier.predict_batch(enhanced_crops)
        print(f"   Seg Results: {len(seg_results)}")
        for i, res in enumerate(seg_results):
            print(f"   [{i}] Type: {res.defect_type}, Ratio: {res.defect_ratio:.4f}")
            print(f"        Mask Shape: {res.mask.shape}, Unique Values: {np.unique(res.mask)}")
    except Exception as e:
        print(f"❌ SegFormer Analysis Failed: {e}")

    print("\n✅ Debug Complete")

if __name__ == "__main__":
    # Use the file path found in previous step
    target_image = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\static\uploads\2026\02\6fd07b0c-1da8-4bd1-bde1-4f32e0832749.jpg"
    debug_cctv(target_image)
