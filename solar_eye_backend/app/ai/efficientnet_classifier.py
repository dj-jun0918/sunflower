"""
Solar Eye Backend - EfficientNet ONNX Classifier

EfficientNet 모델을 사용한 태양광 패널 상태 분류
ONNX Runtime (CPU) 기반 추론

분류 클래스:
- Normal (정상): 결함이 없는 깨끗한 상태
- Crack (균열): 패널 표면의 물리적 파손
- Soiling (오염): 먼지, 새 배설물 등으로 가려진 상태
"""

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple, Optional

import cv2
import numpy as np

try:
    import onnxruntime as ort
except ImportError:
    raise ImportError("onnxruntime이 설치되지 않았습니다. `pip install onnxruntime` 실행 필요")

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    """분류 결과 데이터 클래스"""
    class_name: str
    confidence: float
    class_id: int
    probabilities: List[float]


class EfficientNetClassifier:
    """
    EfficientNet ONNX 기반 패널 상태 분류기
    
    크롭된 패널 이미지를 입력받아 상태 분류 수행
    """
    
    # 분류 클래스 (학습 시 정의된 순서와 일치해야 함)
    CLASSES = ["normal", "crack", "soiling"]
    
    # EfficientNet 입력 크기 (EfficientNetV2-S)
    INPUT_SIZE = 384
    
    # ImageNet 정규화 값
    MEAN = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    STD = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    
    def __init__(self, model_path: str):
        """
        Args:
            model_path: ONNX 모델 파일 경로
        """
        self.model_path = Path(model_path)
        
        if not self.model_path.exists():
            raise FileNotFoundError(f"EfficientNet 모델 파일을 찾을 수 없습니다: {model_path}")
        
        # ONNX Runtime 세션 초기화 (CPU)
        logger.info(f"EfficientNet 모델 로드 중: {model_path}")
        self.session = ort.InferenceSession(
            str(self.model_path),
            providers=["CPUExecutionProvider"]
        )
        
        # 입력/출력 정보
        self.input_name = self.session.get_inputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape
        self.output_name = self.session.get_outputs()[0].name
        
        logger.info(f"EfficientNet 모델 로드 완료 - 입력: {self.input_shape}")
    
    def _preprocess(self, image: np.ndarray) -> np.ndarray:
        """
        이미지 전처리
        
        Args:
            image: BGR 이미지 (OpenCV 형식)
            
        Returns:
            전처리된 텐서 (1, 3, 224, 224)
        """
        # 리사이즈
        resized = cv2.resize(image, (self.INPUT_SIZE, self.INPUT_SIZE))
        
        # BGR -> RGB
        rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
        
        # 정규화: [0, 255] -> [0, 1]
        normalized = rgb.astype(np.float32) / 255.0
        
        # ImageNet 정규화
        normalized = (normalized - self.MEAN) / self.STD
        
        # HWC (TensorFlow/Keras 기반 ONNX는 보통 NHWC 형식을 사용)
        # transposed = normalized.transpose(2, 0, 1)  <-- 제거
        
        # 배치 차원 추가 (1, 384, 384, 3)
        input_tensor = np.expand_dims(normalized, axis=0)
        
        return input_tensor.astype(np.float32)
    
    def _softmax(self, x: np.ndarray) -> np.ndarray:
        """Softmax 함수"""
        exp_x = np.exp(x - np.max(x))
        return exp_x / exp_x.sum()
    
    def classify(self, image: np.ndarray) -> ClassificationResult:
        """
        이미지 분류
        
        Args:
            image: BGR 이미지 (OpenCV 형식, 크롭된 패널 영역)
            
        Returns:
            ClassificationResult
        """
        # 전처리
        input_tensor = self._preprocess(image)
        
        # 추론
        outputs = self.session.run([self.output_name], {self.input_name: input_tensor})
        logits = outputs[0][0]  # (num_classes,)
        
        # Softmax로 확률 계산
        probabilities = self._softmax(logits)
        
        # 최대 확률 클래스
        class_id = int(np.argmax(probabilities))
        confidence = float(probabilities[class_id])
        class_name = self.CLASSES[class_id] if class_id < len(self.CLASSES) else "unknown"
        
        logger.debug(f"분류 결과: {class_name} (신뢰도: {confidence:.4f})")
        
        return ClassificationResult(
            class_name=class_name,
            confidence=confidence,
            class_id=class_id,
            probabilities=probabilities.tolist()
        )
    
    def classify_batch(self, images: List[np.ndarray]) -> List[ClassificationResult]:
        """
        배치 이미지 분류
        
        Args:
            images: BGR 이미지 리스트
            
        Returns:
            ClassificationResult 리스트
        """
        if not images:
            return []
        
        # 배치 전처리
        batch = np.vstack([self._preprocess(img) for img in images])
        
        # 추론
        outputs = self.session.run([self.output_name], {self.input_name: batch})
        logits_batch = outputs[0]
        
        results = []
        for logits in logits_batch:
            probabilities = self._softmax(logits)
            class_id = int(np.argmax(probabilities))
            confidence = float(probabilities[class_id])
            class_name = self.CLASSES[class_id] if class_id < len(self.CLASSES) else "unknown"
            
            results.append(ClassificationResult(
                class_name=class_name,
                confidence=confidence,
                class_id=class_id,
                probabilities=probabilities.tolist()
            ))
        
        return results
    
    @staticmethod
    def map_to_defect_type(class_name: str) -> str:
        """
        분류 결과를 시스템의 DefectType으로 매핑
        
        Args:
            class_name: 분류 클래스명 (normal, crack, soiling)
            
        Returns:
            DefectType 값 (normal, defect, soiling)
        """
        mapping = {
            "normal": "normal",
            "crack": "defect",    # crack은 defect로 매핑
            "soiling": "soiling",
        }
        return mapping.get(class_name, "normal")
    
    @staticmethod
    def map_to_defect_subtype(class_name: str) -> Optional[str]:
        """
        분류 결과를 DefectSubtype으로 매핑
        
        Args:
            class_name: 분류 클래스명
            
        Returns:
            DefectSubtype 값 또는 None
        """
        mapping = {
            "normal": None,
            "crack": "crack",
            "soiling": "dust",  # soiling의 기본 subtype
        }
        return mapping.get(class_name)
