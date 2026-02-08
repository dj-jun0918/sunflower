
import sys
import logging

# Configure logging to stdout
logging.basicConfig(level=logging.DEBUG, stream=sys.stdout)
logger = logging.getLogger(__name__)

print("=== STARTING ISOLATION TEST ===")

try:
    print("1. Importing torch...")
    import torch
    print(f"   Torch version: {torch.__version__}")
    print(f"   CUDA available: {torch.cuda.is_available()}")
except Exception as e:
    print(f"   ERROR importing torch: {e}")

try:
    print("2. Importing cv2...")
    import cv2
    print(f"   OpenCV version: {cv2.__version__}")
except Exception as e:
    print(f"   ERROR importing cv2: {e}")

try:
    print("3. Importing ultralytics...")
    from ultralytics import YOLO
    print("   Ultralytics imported.")
except Exception as e:
    print(f"   ERROR importing ultralytics: {e}")

print("4. Testing Model Loading...")
from app.ai.pipeline import get_pipeline
try:
    print("   Calling get_pipeline()...")
    pipeline = get_pipeline()
    print("   get_pipeline() returned successfully.")
except Exception as e:
    print(f"   ERROR in get_pipeline(): {e}")

print("=== TEST COMPLETE ===")
