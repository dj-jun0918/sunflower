import cv2
import numpy as np
import json

def test_mask_conversion():
    print("Testing Mask Conversion Logic...")

    # 1. Create a dummy mask (50x50) with a "crack" (value 1)
    mask = np.zeros((50, 50), dtype=np.uint8)
    
    # Draw a rectangle as a crack
    cv2.rectangle(mask, (10, 10), (30, 30), 1, -1) # Filled rectangle with value 1
    
    print(f"Mask created. Shape: {mask.shape}, Unique values: {np.unique(mask)}")
    
    # 2. Run conversion logic
    try:
        contours, _ = cv2.findContours(mask.astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        print(f"Contours found: {len(contours)}")
        
        polygons = []
        for i, contour in enumerate(contours):
            print(f"Contour {i} size: {len(contour)}")
            epsilon = 0.005 * cv2.arcLength(contour, True)
            approx = cv2.approxPolyDP(contour, epsilon, True)
            
            points = approx.reshape(-1, 2).tolist()
            print(f"Simplified points: {len(points)}")
            
            if len(points) >= 3:
                polygons.append(points)
        
        if polygons:
            mask_json = json.dumps(polygons)
            print(f"✅ Success! Mask JSON: {mask_json[:100]}...")
        else:
            print("❌ No polygons generated.")
            
    except Exception as e:
        print(f"❌ Exception: {e}")

if __name__ == "__main__":
    test_mask_conversion()
