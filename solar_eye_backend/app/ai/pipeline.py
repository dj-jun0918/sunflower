"""
Solar Eye Backend - AI Pipeline

Dual Track AI Pipeline Optimized for NVIDIA L4 GPU
1. CCTV Track: YOLO -> Real-ESRGAN (x4) -> SegFormer (Pixel-level)
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
from app.ai.real_esrgan import RealESRGANEnhancer
from app.ai.segformer_classifier import SegFormerClassifier, SegmentationResult

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
    태양광 패널 Dual Track AI 분석 파이프라인
    
    Modes:
    - CCTV: Low Res Input -> Enhancer -> SegFormer
    - Drone: High Res Input -> Keras Classifier
    """
    
    def __init__(
        self,
        cctv_yolo_path: str,
        drone_yolo_path: str,
        keras_model_path: str,
        esrgan_model_path: str,
        segformer_model_path: str,
        yolo_conf_threshold: float = 0.2,
        yolo_iou_threshold: float = 0.45,
    ):
        logger.info("Dual Track AI 파이프라인 초기화 중...")
        
        # 1. CCTV Track Components
        logger.info("CCTV Track 모델 로드 중...")
        self.cctv_detector = YOLODetector(
            model_path=cctv_yolo_path,
            conf_threshold=yolo_conf_threshold,
            iou_threshold=yolo_iou_threshold,
        )
        # Lazy loading or immediate? Immediate for now to catch errors early
        try:
            self.enhancer = RealESRGANEnhancer(model_path=esrgan_model_path)
            self.seg_classifier = SegFormerClassifier(model_path=segformer_model_path)
        except Exception as e:
            logger.error(f"CCTV Track 모델 로드 실패 (Enhancer/SegFormer): {e}")
            self.enhancer = None
            self.seg_classifier = None
        
        # 2. Drone Track Components
        logger.info("Drone Track 모델 로드 중...")
        self.drone_detector = YOLODetector(
            model_path=drone_yolo_path,
            conf_threshold=yolo_conf_threshold,
            iou_threshold=yolo_iou_threshold,
        )
        self.keras_classifier = KerasClassifier(
            model_path=keras_model_path,
        )
        
        logger.info("AI 파이프라인 초기화 완료")
    
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
        이미지 분석 (모드에 따른 라우팅)
        """
        if monitoring_type.lower() == "drone":
            return self._analyze_drone(image)
        else:
            return self._analyze_cctv(image)

    def _analyze_drone(self, image: np.ndarray) -> List[PanelAnalysisResult]:
        """드론 파이프라인: YOLO(High) -> Keras"""
        logger.info("🚀 Drone Pipeline 시작")
        results = []
        
        # 1. Detection
        detections = self.drone_detector.detect(image)
        logger.info(f"Drone Detection: {len(detections)} panels")
        
        if not detections:
            return results
            
        # 2. Classification
        for detection in detections:
            try:
                cropped = self._crop_panel(image, detection.bbox)
                
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
                logger.error(f"Drone classification error: {e}")
                continue
                
        return results

    def _analyze_cctv(self, image: np.ndarray) -> List[PanelAnalysisResult]:
        """CCTV 파이프라인: YOLO(Low) -> Enhancer -> SegFormer"""
        logger.info("🎥 CCTV Pipeline 시작")
        results = []
        
        if not self.enhancer or not self.seg_classifier:
            logger.error("CCTV 모델이 로드되지 않아 분석을 수행할 수 없습니다.")
            return []
        
        # 1. Detection
        detections = self.cctv_detector.detect(image)
        logger.info(f"CCTV Detection: {len(detections)} panels")
        
        if not detections:
            return results
            
        # 2. Batch Processing Preparation
        crops = []
        valid_indices = []
        
        for i, detection in enumerate(detections):
            cropped = self._crop_panel(image, detection.bbox)
            if cropped.shape[0] >= 10 and cropped.shape[1] >= 10:
                crops.append(cropped)
                valid_indices.append(i)
        
        if not crops:
            return results
            
        # 3. Batch Enhancement (Real-ESRGAN)
        # Note: RealESRGANer usually processes one by one, or we can loop.
        # Since upscaling is heavy, we process sequentially or in small batches if supported.
        # For simplicity and OOM safety, we process sequentially here but could optimize.
        enhanced_crops = []
        for crop in crops:
            try:
                enhanced = self.enhancer.enhance(crop)
                enhanced_crops.append(enhanced)
            except Exception as e:
                logger.error(f"Enhancement failed: {e}")
                enhanced_crops.append(crop) # Fallback to original
        
        # 4. Batch Classification (SegFormer)
        MAX_BATCH_SIZE = 8 # Adjust based on GPU VRAM
        seg_results = self.seg_classifier.predict_batch(enhanced_crops, batch_size=MAX_BATCH_SIZE)
        
        # 5. Result Synthesis
        for i, seg_result in enumerate(seg_results):
            original_idx = valid_indices[i]
            detection = detections[original_idx]
            
            # Defect Subtype Mapping (Simple logic for now based on SegFormer result)
            defect_subtype = None
            if seg_result.defect_type == "defect": # Crack
                defect_subtype = "crack"
            elif seg_result.defect_type == "soiling":
                defect_subtype = "dust"
                
            results.append(PanelAnalysisResult(
                bbox=detection.bbox,
                panel_confidence=detection.confidence,
                defect_type=seg_result.defect_type,
                defect_subtype=defect_subtype,
                class_confidence=seg_result.defect_ratio, # Conf as ratio
                raw_class_name=seg_result.defect_type,
                mask=seg_result.mask
            ))
            
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
        # 모델 경로 설정
        # Cloud Run에서는 GCS 마운트 경로 사용, 로컬에서는 상대 경로 사용
        gcs_mount_path = Path("/app/ai/models")
        local_path = Path(__file__).parent / "models"
        
        # GCS 마운트 경로가 존재하면 우선 사용
        if gcs_mount_path.exists():
            base_path = gcs_mount_path
            logger.info(f"Using GCS mount path: {base_path}")
        else:
            base_path = local_path
            logger.info(f"Using local path: {base_path}") 
        
        # Models
        cctv_model = base_path / "cctv-yolo26m40000.pt"
        drone_model = base_path / "airshot-yolo26m80k.pt" # Or .onnx if preferred
        keras_model = base_path / "effcienNetmodels.keras"
        esrgan_model = base_path / "RealESRGAN.pth"
        segformer_model = base_path / "segformer"
        
        _pipeline_instance = SolarPanelPipeline(
            cctv_yolo_path=str(cctv_model),
            drone_yolo_path=str(drone_model),
            keras_model_path=str(keras_model),
            esrgan_model_path=str(esrgan_model),
            segformer_model_path=str(segformer_model),
        )
    
    return _pipeline_instance
