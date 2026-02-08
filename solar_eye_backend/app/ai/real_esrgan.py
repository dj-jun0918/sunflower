"""
Solar Eye Backend - Real-ESRGAN Enhancer

CCTV 저화질 영상의 화질 개선을 위한 업스케일링 모듈
"""

import logging
import torch
import numpy as np
import cv2
from pathlib import Path

# Optional imports for Real-ESRGAN
try:
    from basicsr.archs.rrdbnet_arch import RRDBNet
    from realesrgan import RealESRGANer
except ImportError as e:
    RRDBNet = None
    RealESRGANer = None
    # 로깅은 초기화 시점에 수행

logger = logging.getLogger(__name__)

class RealESRGANEnhancer:
    """
    Real-ESRGAN 기반 이미지 업스케일러 (x4)
    """
    
    def __init__(self, model_path: str, scale: int = 4, device: str = 'cuda'):
        if RealESRGANer is None:
            raise ImportError("realesrgan 또는 basicsr 라이브러리가 설치되지 않았습니다.")
            
        self.model_path = Path(model_path)
        self.scale = scale
        self.device = device if torch.cuda.is_available() else 'cpu'
        
        if not self.model_path.exists():
             logger.warning(f"RealESRGAN 모델 파일을 찾을 수 없습니다: {model_path}")
             # 파일이 없어도 초기화는 진행하되, 실행 시 에러 발생 가능
        
        self.upsampler = self._load_model()
        
    def _load_model(self):
        """Real-ESRGAN 모델 로드"""
        try:
            logger.info(f"Real-ESRGAN 모델 로드 중 (Device: {self.device}): {self.model_path}")
            
            # RRDBNet 아키텍처 설정 (x4plus 기준)
            model = RRDBNet(
                num_in_ch=3, 
                num_out_ch=3, 
                num_feat=64, 
                num_block=23, 
                num_grow_ch=32, 
                scale=self.scale
            )
            
            upsampler = RealESRGANer(
                scale=self.scale,
                model_path=str(self.model_path),
                model=model,
                tile=400,            # 메모리 절약을 위한 타일 크기
                tile_pad=10,
                pre_pad=0,
                half=True if self.device == 'cuda' else False, # FP16 (CUDA Only)
                device=self.device,
            )
            
            logger.info("Real-ESRGAN 모델 로드 완료")
            return upsampler
            
        except Exception as e:
            logger.error(f"Real-ESRGAN 로드 실패: {e}")
            raise e

    def enhance(self, image: np.ndarray) -> np.ndarray:
        """
        이미지 업스케일링 실행
        
        Args:
            image: BGR format numpy array (OpenCV)
            
        Returns:
            upscaled image (BGR)
        """
        if self.upsampler is None:
            raise RuntimeError("Real-ESRGAN 모델이 로드되지 않았습니다.")
            
        try:
            # 업스케일링 실행
            output, _ = self.upsampler.enhance(image, outscale=self.scale)
            
            # 메모리 정리
            if self.device == 'cuda':
                torch.cuda.empty_cache()
                
            return output
            
        except Exception as e:
            logger.error(f"이미지 업스케일링 중 오류: {e}")
            # 오류 발생 시 원본 리턴 (서비스 중단을 막기 위함)
            return image
