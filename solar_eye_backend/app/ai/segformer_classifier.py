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
    # 0: Normal, 1: Soiling, 2: Crack
    CLASS_MAP = {
        0: "normal",
        1: "soiling",
        2: "crack"
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
            # FP16 비활성화: 99% 오검출 방지 및 수치 안정성 우선
            # model.half() 
                
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

    def predict_batch(self, images: List[np.ndarray], batch_size: int = 1) -> List[SegmentationResult]:
        """
        배치 단위 추론 (OOM 방지를 위해 기본 배치 크기 1로 축소)
        """
        if not images:
            return []
            
        results = []
        
        # BGR -> RGB 변환 복구 (학습 시 RGB로 학습됨)
        rgb_images = [cv2.cvtColor(img, cv2.COLOR_BGR2RGB) for img in images]
        
        for i in range(0, len(rgb_images), batch_size):
            batch = rgb_images[i : i + batch_size]
            
            try:
                # 전처리
                inputs = self.processor(images=batch, return_tensors="pt")
                inputs = {k: v.to(self.device) for k, v in inputs.items()}
                
                # FP16 대신 Float32 사용 (데이터 정밀도를 위해)
                # if self.device == 'cuda':
                #     inputs["pixel_values"] = inputs["pixel_values"].half()
                
                # 추론
                with torch.no_grad():
                    outputs = self.model(**inputs)
                    
                # 로짓 추출
                logits = outputs.logits  # (B, C, H, W)
                probs = torch.nn.functional.softmax(logits, dim=1) # (B, C, H, W)
                
                # 결과 패키징 (각 이미지별로 업샘플링 수행 - 배치 내 이미지 크기가 다를 수 있음)
                for j in range(len(batch)):
                    # 단일 이미지 로짓/확률 추출
                    single_logits = logits[j:j+1]
                    single_probs = probs[j:j+1]
                    
                    # 해당 이미지의 원본 크기로 업샘플링
                    upsampled_logits = torch.nn.functional.interpolate(
                        single_logits,
                        size=batch[j].shape[:2], # (H, W)
                        mode="bilinear",
                        align_corners=False,
                    )
                    
                    # 마스크 변환 (H, W)
                    mask = upsampled_logits.argmax(dim=1).squeeze(0).cpu().numpy()
                    
                    # --- RAW DEBUG (사용자 요청 시 활성화 가능) ---
                    # if j == 0: 
                    #     avg_probs = single_probs.mean(dim=(2, 3)).squeeze().cpu().numpy()
                    #     print(f"DEBUG: [RAW] Avg Probs: {avg_probs}")
                    
                    results.append(self._analyze_mask(mask))
                
                # 메모리 정리 (배치별)
                if self.device == 'cuda':
                    torch.cuda.empty_cache()
                
                # predicted_masks = upsampled_logits.argmax(dim=1).cpu().numpy() # (B, H, W) 제거됨
                
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
        """마스크 분석하여 결함 유형 결정 (정교화된 판단 로직)"""
        total_pixels = mask.size
        
        # 0: Normal, 1: Soiling, 2: Crack (Model config.json 기준)
        normal_pixels = np.count_nonzero(mask == 0)
        soiling_pixels = np.count_nonzero(mask == 1)
        crack_pixels = np.count_nonzero(mask == 2)
        
        crack_ratio = crack_pixels / total_pixels
        soiling_ratio = soiling_pixels / total_pixels
        normal_ratio = normal_pixels / total_pixels
        
        # DEBUG LOGGING
        if crack_pixels > 0 or soiling_pixels > 0:
            print(f"🔍 SegFormer [RAW]: Normal={normal_ratio:.4f}, Crack={crack_ratio:.4f}, Soiling={soiling_ratio:.4f}")
        
        # 결함 판정 로직 (Normal 클래스가 지배적이지 않거나, 결함 비율이 충분히 높을 때)
        # 1. Crack 우선 판단 (더 치명적임)
        if crack_ratio > 0.05 and crack_ratio > soiling_ratio:
            defect_type = "defect"
            confidence = 0.5 + (crack_ratio * 0.5)
        # 2. Soiling 판단
        elif soiling_ratio > 0.05:
            defect_type = "soiling"
            confidence = 0.5 + (soiling_ratio * 0.5)
        # 3. Normal (Normal이 70% 이상이거나 결함 비율이 낮을 때)
        else:
            defect_type = "normal"
            confidence = normal_ratio
            
        return SegmentationResult(
            mask=mask.astype(np.uint8),
            defect_type=defect_type,
            defect_ratio=max(crack_ratio, soiling_ratio),
            confidence=confidence
        )
