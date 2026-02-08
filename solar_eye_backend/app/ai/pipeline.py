"""
Solar Eye Backend - AI Pipeline

Dual Track AI Pipeline Optimized for NVIDIA L4 GPU (Lightweight)
1. CCTV Track: YOLO -> Keras Classifier
2. Drone Track: YOLO (High-Res) -> Keras Classifier
"""

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

import cv2
import numpy as np

from app.ai.yolo_detector import YOLODetector, BoundingBox
from app.ai.keras_classifier import KerasClassifier, ClassificationResult

logger = logging.getLogger(__name__)


@dataclass
class PanelAnalysisResult:
    """패널 분석 결과 데이터 클래스"""
    # 위치 정보 (YOLO 탐지 결과)
    bbox: BoundingBox
    panel_confidence: float
    
    # 상태 분류 정보
    defect_type: str        # normal, defect, soiling
    defect_subtype: Optional[str]  # crack, dust, etc.
    class_confidence: float
    
    # 원본 분류 클래스명
    raw_class_name: str     # normal, crack, soiling
    
    # (Optional) 세그멘테이션 마스크
    mask: Optional[np.ndarray] = None
    
    @property
    def is_defect(self) -> bool:
        """결함 여부"""
        return self.defect_type in ("defect", "soiling")
    
    @property
    def area_percentage(self) -> float:
        """이미지 대비 패널 영역 비율 (추후 계산)"""
        return 0.0


class SolarPanelPipeline:
    """
    태양광 패널 Dual Track AI 분석 파이프라인 (Lightweight Version)
    
    Modes:
    - CCTV: YOLO (Low Res) -> Keras Classifier
    - Drone: YOLO (High Res) -> Keras Classifier
    """
    
    def __init__(
        self,
        cctv_yolo_path: str,
        drone_yolo_path: str,
        keras_model_path: str,
        yolo_conf_threshold: float = 0.2,
        yolo_iou_threshold: float = 0.45,
    ):
        print("DEBUG: SolarPanelPipeline (Lightweight) initializing...")
        logger.info("AI 파이프라인 (Lightweight) 초기화 중...")
        
        # 1. CCTV Track Components
        logger.info("CCTV Track 모델 로드 중...")
        print(f"DEBUG: Loading CCTV YOLO from {cctv_yolo_path}")
        try:
            self.cctv_detector = YOLODetector(
                model_path=cctv_yolo_path,
                conf_threshold=yolo_conf_threshold,
                iou_threshold=yolo_iou_threshold,
            )
            print("DEBUG: CCTV YOLO loaded successfully.")
        except Exception as e:
            print(f"DEBUG: Failed to load CCTV YOLO: {e}")
            logger.error(f"CCTV YOLO Load Error: {e}")
            raise

        # 2. Drone Track Components
        logger.info("Drone Track 모델 로드 중...")
        try:
            print(f"DEBUG: Loading Drone YOLO from {drone_yolo_path}")
            self.drone_detector = YOLODetector(
                model_path=drone_yolo_path,
                conf_threshold=yolo_conf_threshold,
                iou_threshold=yolo_iou_threshold,
            )
            print("DEBUG: Drone YOLO loaded.")
        except Exception as e:
            print(f"DEBUG: Drone YOLO load failed: {e}")
            logger.error(f"Drone YOLO Load Error: {e}")
            raise

        # 3. Shared Classifier (Keras)
        logger.info("Keras Classifier 로드 중...")
        try:
            print(f"DEBUG: Loading Keras Classifier from {keras_model_path}")
            self.keras_classifier = KerasClassifier(
                model_path=keras_model_path,
            )
            print("DEBUG: Keras Classifier loaded.")
        except Exception as e:
            print(f"DEBUG: Keras Classifier load failed: {e}")
            logger.error(f"Keras Classifier Load Error: {e}")
            raise
        
        logger.info("AI 파이프라인 초기화 완료")
        print("DEBUG: SolarPanelPipeline initialization COMPLETE.")

    def _crop_panel(
        self, 
        image: np.ndarray, 
        bbox: BoundingBox, 
        padding_ratio: float = 0.15
    ) -> np.ndarray:
        """이미지에서 패널 영역 크롭 (15% 패딩 포함)"""
        width = bbox.width
        height = bbox.height
        pad_x = int(width * padding_ratio)
        pad_y = int(height * padding_ratio)
        
        x1 = max(0, bbox.x - pad_x)
        y1 = max(0, bbox.y - pad_y)
        x2 = min(image.shape[1], bbox.x2 + pad_x)
        y2 = min(image.shape[0], bbox.y2 + pad_y)
        
        return image[y1:y2, x1:x2].copy()
    
    def analyze(self, image: np.ndarray, monitoring_type: str = "cctv") -> List[PanelAnalysisResult]:
        """
        이미지 분석 (모드에 따른 라우팅 -> 공통 로직으로 통합 가능하지만 모델이 다름)
        """
        if monitoring_type.lower() == "drone":
            detector = self.drone_detector
            logger.info("🚀 Drone Pipeline 시작")
        else:
            detector = self.cctv_detector
            logger.info("🎥 CCTV Pipeline 시작")

        return self._analyze_common(image, detector)

    def _analyze_common(self, image: np.ndarray, detector: YOLODetector) -> List[PanelAnalysisResult]:
        """공통 분석 로직: YOLO -> Keras Classify"""
        results = []
        
        # 1. Detection
        try:
            detections = detector.detect(image)
            logger.info(f"Detection found: {len(detections)} panels")
        except Exception as e:
            logger.error(f"Detection failed: {e}")
            print(f"DEBUG: Detection failed: {e}")
            return []
        
        if not detections:
            return results
            
        # 2. Classification per panel
        for detection in detections:
            try:
                cropped = self._crop_panel(image, detection.bbox)
                
                # 너무 작은 이미지는 스킵
                if cropped.shape[0] < 10 or cropped.shape[1] < 10:
                    continue
                
                classification = self.keras_classifier.classify(cropped)
                
                defect_type = KerasClassifier.map_to_defect_type(classification.class_name)
                defect_subtype = KerasClassifier.map_to_defect_subtype(classification.class_name)
                
                results.append(PanelAnalysisResult(
                    bbox=detection.bbox,
                    panel_confidence=detection.confidence,
                    defect_type=defect_type,
                    defect_subtype=defect_subtype,
                    class_confidence=classification.confidence,
                    raw_class_name=classification.class_name,
                ))
            except Exception as e:
                logger.error(f"Classification error for panel: {e}")
                continue
                
        return results

    # Legacy wrappers
    def analyze_from_file(self, image_path: str) -> List[PanelAnalysisResult]:
        image = cv2.imread(image_path)
        if image is None: raise ValueError(f"Image load failed: {image_path}")
        return self.analyze(image)
    
    def analyze_from_bytes(self, image_bytes: bytes) -> List[PanelAnalysisResult]:
        nparr = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if image is None: raise ValueError("Image decode failed")
        return self.analyze(image)


# 싱글톤 파이프라인 인스턴스
_pipeline_instance: Optional[SolarPanelPipeline] = None


def get_pipeline() -> SolarPanelPipeline:
    """
    파이프라인 싱글톤 인스턴스 반환
    """
    global _pipeline_instance
    
    if _pipeline_instance is None:
        print("DEBUG: get_pipeline() called. Creating new instance.")
        # 모델 경로 설정
        # app/ai/models로 모든 모델이 집중되어 있다고 가정 (User confirmed this path)
        base_path = Path(__file__).parent / "models" 
        print(f"DEBUG: Model base path: {base_path.absolute()}")
        
        # Models
        cctv_model = base_path / "yolo26m40000_weights_best.pt"
        drone_model = base_path / "yolo26m80k_weights_best.pt"
        keras_model = base_path / "best_solar_model.keras"
        
        # Check existence
        for p in [cctv_model, drone_model, keras_model]:
            if not p.exists():
                print(f"DEBUG: CRITICAL - Model file missing: {p}")
        
        try:
            _pipeline_instance = SolarPanelPipeline(
                cctv_yolo_path=str(cctv_model),
                drone_yolo_path=str(drone_model),
                keras_model_path=str(keras_model),
            )
        except Exception as e:
            print(f"DEBUG: Pipeline creation failed: {e}")
            raise
    
    return _pipeline_instance
