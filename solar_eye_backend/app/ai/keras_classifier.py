"""
Solar Eye Backend - Keras Classifier

Keras(.keras) 모델을 사용한 태양광 패널 상태 분류
TensorFlow 기반 추론
"""

import logging
import os
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

# Keras 3 Read-only filesystem fix
os.environ['KERAS_HOME'] = '/tmp/keras'

import cv2
import numpy as np

try:
    import tensorflow as tf
    import keras
except ImportError as e:
    raise ImportError(f"tensorflow 로드 실패. 상세 에러: {e}\n`pip install tensorflow`를 확인해주세요.")

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    """분류 결과 데이터 클래스"""
    class_name: str
    confidence: float
    class_id: int
    probabilities: List[float]


class KerasClassifier:
    """
    Keras 기반 패널 상태 분류기
    """
    
    # 분류 클래스 (학습 시 정의된 순서와 일치해야 함)
    # User provided: 'Crack', 'Normal', 'Soiling'
    CLASSES = ["Crack", "Normal", "Soiling"]
    
    # Keras 모델 입력 크기
    INPUT_SIZE = 384
    
    def __init__(self, model_path: str):
        """
        Args:
            model_path: Keras 모델 파일 경로 (.keras)
        """
        self.model_path = Path(model_path)
        
        if not self.model_path.exists():
            raise FileNotFoundError(f"Keras 모델 파일을 찾을 수 없습니다: {model_path}")
        
        # 모델 로드
        logger.info(f"Keras 모델 로드 중: {model_path}")
        try:
            # compile=False: 학습 설정 무시
            # safe_mode=False: Keras 3 데시리얼라이즈 보안 검사 우회 (이전 버전 모델 호환성)
            self.model = keras.models.load_model(self.model_path, compile=False, safe_mode=False)
            logger.info("Keras 모델 로드 완료")
            
            # 모델 입력 형상 확인 (가능한 경우)
            try:
                input_shape = self.model.input_shape
                if input_shape and len(input_shape) >= 2:
                    current_size = input_shape[1]
                    if current_size != self.INPUT_SIZE:
                        logger.warning(f"설정된 입력 크기({self.INPUT_SIZE})가 모델({current_size})과 다릅니다. 모델 설정으로 자동 변경합니다.")
                        self.INPUT_SIZE = current_size
                    logger.info(f"모델 입력 크기: {self.INPUT_SIZE}")
            except Exception:
                pass
                
        except Exception as e:
            logger.error(f"Keras 모델 로드 실패: {e}")
            raise e

    def _preprocess(self, image: np.ndarray) -> np.ndarray:
        """
        이미지 전처리
        
        Args:
            image: BGR 이미지 (OpenCV 형식)
            
        Returns:
            전처리된 배치 텐서 (1, 384, 384, 3)
        """
        # 리사이즈
        resized = cv2.resize(image, (self.INPUT_SIZE, self.INPUT_SIZE))
        
        # BGR -> RGB
        rgb = cv2.cvtColor(resized, cv2.COLOR_BGR2RGB)
        
        # float32 변환 (0~255 범위 유지 - 학습 시와 동일)
        # 주의: 학습 시 rescaling 레이어 없이 0~255로 학습됨
        normalized = rgb.astype(np.float32)
        
        # 배치 차원 추가
        batch = np.expand_dims(normalized, axis=0)
        
        return batch

    def classify(self, image: np.ndarray, use_tta: bool = False) -> ClassificationResult:
        """
        이미지 분류
        
        Args:
            image: BGR 이미지 (OpenCV 형식, 크롭된 패널 영역)
            use_tta: TTA(Test-Time Augmentation) 사용 여부 (기본값 False)
            
        Returns:
            ClassificationResult
        """
        if use_tta:
            return self._classify_with_tta(image)
        
        # 전처리
        input_tensor = self._preprocess(image)
        
        # 추론
        predictions = self.model.predict(input_tensor, verbose=0)
        probabilities = predictions[0]  # (num_classes,)
        
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
    
    def _classify_with_tta(self, image: np.ndarray) -> ClassificationResult:
        """
        TTA(Test-Time Augmentation) 적용 분류
        
        동일 이미지를 여러 변환(원본, 좌우반전, 90도/270도 회전)하여 
        추론 후 평균 확률을 사용해 안정성 향상
        
        Args:
            image: BGR 이미지 (OpenCV 형식)
            
        Returns:
            ClassificationResult (평균 확률 기반)
        """
        # 증강 이미지 생성
        augmented_images = [
            image,                                          # 원본
            cv2.flip(image, 1),                             # 좌우 반전
            cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE),     # 90도 회전
            cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE),  # 270도 회전
        ]
        
        # 배치 전처리
        batch = np.vstack([self._preprocess(img) for img in augmented_images])
        
        # 배치 추론 (한 번에 여러 이미지 처리)
        predictions = self.model.predict(batch, verbose=0)
        
        # 평균 확률 계산
        avg_probabilities = np.mean(predictions, axis=0)
        
        # ========== 디버깅 로그 (클래스별 확률 상세 출력) ==========
        print("=" * 60)
        print("[TTA 분류 상세 확률] - 클래스 순서 확인용")
        for i, cls_name in enumerate(self.CLASSES):
            prob = avg_probabilities[i] if i < len(avg_probabilities) else 0
            bar = "█" * int(prob * 20)  # 시각화
            print(f"  [{i}] {cls_name:10s}: {prob:.4f} ({prob*100:5.1f}%) {bar}")
        print(f"  → 현재 클래스 순서: {self.CLASSES}")
        print("=" * 60)
        # =========================================================
        
        # 최대 확률 클래스
        class_id = int(np.argmax(avg_probabilities))
        confidence = float(avg_probabilities[class_id])
        class_name = self.CLASSES[class_id] if class_id < len(self.CLASSES) else "unknown"
        
        logger.info(f"[TTA 최종 결과] {class_name} (신뢰도: {confidence:.4f})")
        
        return ClassificationResult(
            class_name=class_name,
            confidence=confidence,
            class_id=class_id,
            probabilities=avg_probabilities.tolist()
        )

    def classify_batch(self, images: List[np.ndarray]) -> List[ClassificationResult]:
        """
        배치 이미지 분류
        """
        if not images:
            return []
        
        # 배치 전처리
        # 각 이미지를 전처리(배치차원 포함)한 뒤 vstack으로 병합
        batch = np.vstack([self._preprocess(img) for img in images])
        
        # 추론
        predictions = self.model.predict(batch, verbose=0)
        
        results = []
        for probs in predictions:
            class_id = int(np.argmax(probs))
            confidence = float(probs[class_id])
            class_name = self.CLASSES[class_id] if class_id < len(self.CLASSES) else "unknown"
            
            results.append(ClassificationResult(
                class_name=class_name,
                confidence=confidence,
                class_id=class_id,
                probabilities=probs.tolist()
            ))
        
        return results

    @staticmethod
    def map_to_defect_type(class_name: str) -> str:
        """
        분류 결과를 시스템의 DefectType으로 매핑
        """
        # 소문자 변환하여 매핑
        lower_name = class_name.lower()
        mapping = {
            "normal": "normal",
            "crack": "defect",
            "soiling": "soiling",
        }
        return mapping.get(lower_name, "normal")
    
    @staticmethod
    def map_to_defect_subtype(class_name: str) -> Optional[str]:
        """
        분류 결과를 DefectSubtype으로 매핑
        """
        lower_name = class_name.lower()
        mapping = {
            "normal": None,
            "crack": "crack",
            "soiling": "dust",
        }
        return mapping.get(lower_name)
