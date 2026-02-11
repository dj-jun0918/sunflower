"""
Solar Eye Backend - SegFormer Classifier

업스케일된 고화질 패널 이미지의 픽셀 단위 결함 분류
"""

import logging
import torch
import numpy as np
import cv2
from pathlib import Path
from dataclasses import dataclass
from typing import List, Tuple, Optional

try:
    from transformers import SegformerForSemanticSegmentation, SegformerImageProcessor
except ImportError:
    SegformerForSemanticSegmentation = None
    SegformerImageProcessor = None

logger = logging.getLogger(__name__)

@dataclass
class SegmentationResult:
    """세그멘테이션 결과"""
    mask: np.ndarray       # Class Map
    defect_type: str       # 대표 결함 유형 (normal/defect/soiling)
    defect_ratio: float    # 결함 영역 비율
    confidence: float      # 분류 신뢰도

class SegFormerClassifier:
    """
    SegFormer 기반 시맨틱 세그멘테이션 분류기
    """
    
    # 클래스 매핑 (모델 학습 시 정의된 ID)
    # 0: Background/Normal, 1: Crack, 2: Soiling (가장 일반적인 설정, 모델에 따라 다를 수 있음)
    # 사용자 정의에 따라 수정 필요할 수 있음
    CLASS_MAP = {
        0: "normal",
        1: "crack",
        2: "soiling"
    }
    
    def __init__(self, model_path: str, device: str = 'cuda'):
        if SegformerForSemanticSegmentation is None:
            raise ImportError("transformers 라이브러리가 필요합니다.")
            
        self.model_path = Path(model_path)
        self.device = device if torch.cuda.is_available() else 'cpu'
        
        self.model, self.processor = self._load_model()
        
    def _load_model(self):
        """SegFormer 모델 로드"""
        try:
            logger.info(f"SegFormer 모델 로드 중 (Device: {self.device}): {self.model_path}")
            
            # 모델 로드 (Local Files Only)
            model = SegformerForSemanticSegmentation.from_pretrained(
                str(self.model_path), 
                local_files_only=True
            )
            
            # 프로세서 로드
            processor = SegformerImageProcessor.from_pretrained(
                str(self.model_path),
                local_files_only=True
            )
            
            # GPU 이동 및 최적화
            model.to(self.device)
            if self.device == 'cuda':
                model.half() # FP16
                
            model.eval()
            
            logger.info("SegFormer 모델 로드 완료")
            return model, processor
            
        except Exception as e:
            logger.error(f"SegFormer 로드 실패: {e}")
            raise e

    def predict(self, image: np.ndarray) -> SegmentationResult:
        """
        단일 이미지 추론
        """
        # 배치 처리 메서드 재사용
        results = self.predict_batch([image])
        return results[0] if results else None

    def predict_batch(self, images: List[np.ndarray], batch_size: int = 4) -> List[SegmentationResult]:
        """
        배치 단위 추론
        """
        if not images:
            return []
            
        results = []
        
        # BGR -> RGB 변환
        rgb_images = [cv2.cvtColor(img, cv2.COLOR_BGR2RGB) for img in images]
        
        for i in range(0, len(rgb_images), batch_size):
            batch = rgb_images[i : i + batch_size]
            
            try:
                # 전처리
                inputs = self.processor(images=batch, return_tensors="pt")
                inputs = {k: v.to(self.device) for k, v in inputs.items()}
                
                if self.device == 'cuda':
                    inputs["pixel_values"] = inputs["pixel_values"].half()

                # 추론
                with torch.no_grad():
                    outputs = self.model(**inputs)
                    
                # 로짓 -> 클래스 맵 변환
                # interpolation으로 원본 크기 복원 (또는 입력 크기 512x512)
                logits = outputs.logits  # (B, C, H, W)
                
                # 업샘플링 (입력 이미지 크기에 맞춤 - 여기서는 512x512 가정)
                upsampled_logits = torch.nn.functional.interpolate(
                    logits,
                    size=batch[0].shape[:2], # (H, W)
                    mode="bilinear",
                    align_corners=False,
                )
                
                predicted_masks = upsampled_logits.argmax(dim=1).cpu().numpy() # (B, H, W)
                
                # 결과 패키징
                for mask in predicted_masks:
                    results.append(self._analyze_mask(mask))
                
                pass
                    
            except Exception as e:
                logger.error(f"SegFormer 배치 추론 중 오류: {e}")
                # 오류 시 빈 결과 추가 (개수 맞춤)
                for _ in batch:
                    results.append(SegmentationResult(
                        mask=np.zeros((1, 1), dtype=np.uint8), 
                        defect_type="normal",  # fallback to valid DB enum 
                        defect_ratio=0.0,
                        confidence=0.0
                    ))
                    
        return results

    def _analyze_mask(self, mask: np.ndarray) -> SegmentationResult:
        """마스크 분석하여 결함 유형 결정"""
        total_pixels = mask.size
        
        # 0: Normal, 1: Crack, 2: Soiling
        crack_pixels = np.count_nonzero(mask == 1)
        soiling_pixels = np.count_nonzero(mask == 2)
        
        crack_ratio = crack_pixels / total_pixels
        soiling_ratio = soiling_pixels / total_pixels
        
        # 결함 판정 (임계값 0.5% - 상향 조정)
        if crack_ratio > 0.005:
            defect_type = "defect" # Crack -> Defect
            confidence = 0.5 + (crack_ratio * 0.5) # Base 0.5 + ratio
        elif soiling_ratio > 0.005:
            defect_type = "soiling"
            confidence = 0.5 + (soiling_ratio * 0.5) # Base 0.5 + ratio
        else:
            defect_type = "normal"
            confidence = 1.0 - max(crack_ratio, soiling_ratio)
            
        return SegmentationResult(
            mask=mask.astype(np.uint8),
            defect_type=defect_type,
            defect_ratio=max(crack_ratio, soiling_ratio),
            confidence=confidence
        )
