"""
Script to verify Phase 2: AI Model Integration
Tests:
1. ModelLoader logic (YOLODetector)
2. SolarPanelPipeline initialization
3. Model file loading (checks if .pt/.pkl files exist and are loadable)
"""
import sys
import os
import asyncio
import logging
import numpy as np

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.ai.pipeline import get_pipeline, SolarPanelPipeline

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("verify_result.log", encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

def test_pipeline_init():
    logger.info("Testing Pipeline Initialization...")
    try:
        pipeline = get_pipeline()
        logger.info("✅ Pipeline initialized successfully.")
        
        # Check if detectors are initialized
        if pipeline.cctv_detector:
            logger.info("✅ CCTV Detector initialized.")
            logger.info(f"   - Model Type: {pipeline.cctv_detector.model_type}")
            logger.info(f"   - Path: {pipeline.cctv_detector.model_path}")
        else:
            logger.error("❌ CCTV Detector failed to initialize.")

        if pipeline.drone_detector:
            logger.info("✅ Drone Detector initialized.")
            logger.info(f"   - Model Type: {pipeline.drone_detector.model_type}")
        else:
            logger.error("❌ Drone Detector failed to initialize.")
            
        return pipeline
    except Exception as e:
        logger.error(f"❌ Pipeline initialization failed: {e}")
        return None

def test_inference_mock(pipeline):
    """Running a mock inference to check logic flow (not accuracy)"""
    logger.info("\nTesting Mock Inference Logic...")
    
    # Create a blank dummy image (640x640, 3 channels)
    dummy_image = np.zeros((640, 640, 3), dtype=np.uint8)
    
    try:
        # Test 1: CCTV Mode
        logger.info("Testing CCTV Mode Inference...")
        results_cctv = pipeline.analyze(dummy_image, monitoring_type="cctv")
        logger.info(f"✅ CCTV Inference ran without error (Results: {len(results_cctv)})")

        # Test 2: Drone Mode
        logger.info("Testing Drone Mode Inference...")
        results_drone = pipeline.analyze(dummy_image, monitoring_type="drone")
        logger.info(f"✅ Drone Inference ran without error (Results: {len(results_drone)})")

    except Exception as e:
        logger.error(f"❌ Inference logic failed: {e}")

if __name__ == "__main__":
    print("="*50)
    print("STARTING AI INTEGATION VERIFICATION")
    print("="*50)
    
    pipeline = test_pipeline_init()
    
    if pipeline:
        test_inference_mock(pipeline)
    
    print("="*50)
    print("VERIFICATION COMPLETE")
    print("="*50)
