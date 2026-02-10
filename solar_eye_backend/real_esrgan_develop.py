"""
Solar Eye Backend - Real-ESRGAN Enhancer

CCTV ??붿쭏 ?곸긽???붿쭏 媛쒖꽑???꾪븳 ?낆뒪耳?쇰쭅 紐⑤뱢
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
    # 濡쒓퉭? 珥덇린???쒖젏???섑뻾

logger = logging.getLogger(__name__)

class RealESRGANEnhancer:
    """
    Real-ESRGAN 湲곕컲 ?대?吏 ?낆뒪耳?쇰윭 (x4)
    """
    
    def __init__(self, model_path: str, scale: int = 4, device: str = 'cuda'):
        if RealESRGANer is None:
            raise ImportError("realesrgan ?먮뒗 basicsr ?쇱씠釉뚮윭由ш? ?ㅼ튂?섏? ?딆븯?듬땲??")
            
        self.model_path = Path(model_path)
        self.scale = scale
        self.device = device if torch.cuda.is_available() else 'cpu'
        
        if not self.model_path.exists():
             logger.warning(f"RealESRGAN 紐⑤뜽 ?뚯씪??李얠쓣 ???놁뒿?덈떎: {model_path}")
             # ?뚯씪???놁뼱??珥덇린?붾뒗 吏꾪뻾?섎릺, ?ㅽ뻾 ???먮윭 諛쒖깮 媛??        
        self.upsampler = self._load_model()
        
    def _load_model(self):
        """Real-ESRGAN 紐⑤뜽 濡쒕뱶"""
        try:
            logger.info(f"Real-ESRGAN 紐⑤뜽 濡쒕뱶 以?(Device: {self.device}): {self.model_path}")
            
            # RRDBNet ?꾪궎?띿쿂 ?ㅼ젙 (x4plus 湲곗?)
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
                tile=400,            # 硫붾え由??덉빟???꾪븳 ????ш린
                tile_pad=10,
                pre_pad=0,
                half=True if self.device == 'cuda' else False, # FP16 (CUDA Only)
                device=self.device,
            )
            
            logger.info("Real-ESRGAN 紐⑤뜽 濡쒕뱶 ?꾨즺")
            return upsampler
            
        except Exception as e:
            logger.error(f"Real-ESRGAN 濡쒕뱶 ?ㅽ뙣: {e}")
            raise e

    def enhance(self, image: np.ndarray) -> np.ndarray:
        """
        ?대?吏 ?낆뒪耳?쇰쭅 ?ㅽ뻾
        
        Args:
            image: BGR format numpy array (OpenCV)
            
        Returns:
            upscaled image (BGR)
        """
        if self.upsampler is None:
            raise RuntimeError("Real-ESRGAN 紐⑤뜽??濡쒕뱶?섏? ?딆븯?듬땲??")
            
        try:
            # ?낆뒪耳?쇰쭅 ?ㅽ뻾
            output, _ = self.upsampler.enhance(image, outscale=self.scale)
            
            # 硫붾え由??뺣━
            if self.device == 'cuda':
                torch.cuda.empty_cache()
                
            return output
            
        except Exception as e:
            logger.error(f"?대?吏 ?낆뒪耳?쇰쭅 以??ㅻ쪟: {e}")
            # ?ㅻ쪟 諛쒖깮 ???먮낯 由ы꽩 (?쒕퉬??以묐떒??留됯린 ?꾪븿)
            return image
