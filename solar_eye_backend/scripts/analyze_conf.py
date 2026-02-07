import sys
import os
import cv2
import numpy as np
from pathlib import Path
from ultralytics import YOLO

def analyze_confidence(model_path, image_dir):
    print(f"--- Analyzing Confidence for: {model_path} ---")
    model = YOLO(model_path)
    
    image_paths = list(Path(image_dir).rglob("*.jpg")) + list(Path(image_dir).rglob("*.png"))
    
    all_confs = []
    
    for img_path in image_paths[:20]:
        image = cv2.imread(str(img_path))
        if image is None: continue
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        results = model.predict(image_rgb, conf=0.01, imgsz=1024, verbose=False) # Very low conf to see all
        
        confs = []
        for r in results:
            for box in r.boxes:
                confs.append(float(box.conf[0]))
        
        if confs:
            print(f"Image {img_path.name}: Max Conf: {max(confs):.4f}, Avg Conf: {np.mean(confs):.4f}, Count: {len(confs)}")
            all_confs.extend(confs)
        else:
            print(f"Image {img_path.name}: 0 detections even at 0.01")

    if all_confs:
        print("\n--- Summary Statistics ---")
        print(f"Total Detections: {len(all_confs)}")
        print(f"Min Conf: {min(all_confs):.4f}")
        print(f"Max Conf: {max(all_confs):.4f}")
        print(f"Mean Conf: {np.mean(all_confs):.4f}")
        print(f"Median Conf: {np.median(all_confs):.4f}")
        
        # Check how many are above 0.25, 0.4, 0.5
        for t in [0.2, 0.25, 0.3, 0.4, 0.5]:
            count = sum(1 for c in all_confs if c >= t)
            print(f"Detections above {t}: {count} ({count/len(all_confs)*100:.1f}%)")

if __name__ == "__main__":
    cctv_model_path = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\app\ai\models\yolo26m40000_weights_best.pt"
    upload_dir = r"c:\Users\dgjun\workspace\solar_eye\solar_eye_backend\static\uploads"
    analyze_confidence(cctv_model_path, upload_dir)
