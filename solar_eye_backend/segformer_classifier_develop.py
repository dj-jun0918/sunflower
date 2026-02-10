"""
Solar Eye Backend - SegFormer Classifier

?낆뒪耳?쇰맂 怨좏솕吏??⑤꼸 ?대?吏???쎌? ?⑥쐞 寃고븿 遺꾨쪟
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
    """?멸렇硫섑뀒?댁뀡 寃곌낵"""
    mask: np.ndarray       # Class Map
    defect_type: str       # ???寃고븿 ?좏삎 (normal/defect/soiling)
    defect_ratio: float    # 寃고븿 ?곸뿭 鍮꾩쑉

class SegFormerClassifier:
    """
    SegFormer 湲곕컲 ?쒕㎤???멸렇硫섑뀒?댁뀡 遺꾨쪟湲?    """
    
    # ?대옒??留ㅽ븨 (紐⑤뜽 ?숈뒿 ???뺤쓽??ID)
    # 0: Background/Normal, 1: Crack, 2: Soiling (媛???쇰컲?곸씤 ?ㅼ젙, 紐⑤뜽???곕씪 ?ㅻ? ???덉쓬)
    # ?ъ슜???뺤쓽???곕씪 ?섏젙 ?꾩슂?????덉쓬
    CLASS_MAP = {
        0: "normal",
        1: "crack",
        2: "soiling"
    }
    
    def __init__(self, model_path: str, device: str = 'cuda'):
        if SegformerForSemanticSegmentation is None:
            raise ImportError("transformers ?쇱씠釉뚮윭由ш? ?꾩슂?⑸땲??")
            
        self.model_path = Path(model_path)
        self.device = device if torch.cuda.is_available() else 'cpu'
        
        self.model, self.processor = self._load_model()
        
    def _load_model(self):
        """SegFormer 紐⑤뜽 濡쒕뱶"""
        try:
            logger.info(f"SegFormer 紐⑤뜽 濡쒕뱶 以?(Device: {self.device}): {self.model_path}")
            
            # 紐⑤뜽 濡쒕뱶 (Local Files Only)
            model = SegformerForSemanticSegmentation.from_pretrained(
                str(self.model_path), 
                local_files_only=True
            )
            
            # ?꾨줈?몄꽌 濡쒕뱶
            processor = SegformerImageProcessor.from_pretrained(
                str(self.model_path),
                local_files_only=True
            )
            
            # GPU ?대룞 諛?理쒖쟻??            model.to(self.device)
            if self.device == 'cuda':
                model.half() # FP16
                
            model.eval()
            
            logger.info("SegFormer 紐⑤뜽 濡쒕뱶 ?꾨즺")
            return model, processor
            
        except Exception as e:
            logger.error(f"SegFormer 濡쒕뱶 ?ㅽ뙣: {e}")
            raise e

    def predict(self, image: np.ndarray) -> SegmentationResult:
        """
        ?⑥씪 ?대?吏 異붾줎
        """
        # 諛곗튂 泥섎━ 硫붿꽌???ъ궗??        results = self.predict_batch([image])
        return results[0] if results else None

    def predict_batch(self, images: List[np.ndarray], batch_size: int = 4) -> List[SegmentationResult]:
        """
        諛곗튂 ?⑥쐞 異붾줎
        """
        if not images:
            return []
            
        results = []
        
        # BGR -> RGB 蹂??        rgb_images = [cv2.cvtColor(img, cv2.COLOR_BGR2RGB) for img in images]
        
        for i in range(0, len(rgb_images), batch_size):
            batch = rgb_images[i : i + batch_size]
            
            try:
                # ?꾩쿂由?                inputs = self.processor(images=batch, return_tensors="pt")
                inputs = {k: v.to(self.device) for k, v in inputs.items()}
                
                if self.device == 'cuda':
                    inputs["pixel_values"] = inputs["pixel_values"].half()

                # 異붾줎
                with torch.no_grad():
                    outputs = self.model(**inputs)
                    
                # 濡쒖쭞 -> ?대옒??留?蹂??                # interpolation?쇰줈 ?먮낯 ?ш린 蹂듭썝 (?먮뒗 ?낅젰 ?ш린 512x512)
                logits = outputs.logits  # (B, C, H, W)
                
                # ?낆깦?뚮쭅 (?낅젰 ?대?吏 ?ш린??留욎땄 - ?ш린?쒕뒗 512x512 媛??
                upsampled_logits = torch.nn.functional.interpolate(
                    logits,
                    size=batch[0].shape[:2], # (H, W)
                    mode="bilinear",
                    align_corners=False,
                )
                
                predicted_masks = upsampled_logits.argmax(dim=1).cpu().numpy() # (B, H, W)
                
                # 寃곌낵 ?⑦궎吏?                for mask in predicted_masks:
                    results.append(self._analyze_mask(mask))
                
                # 硫붾え由??뺣━
                if self.device == 'cuda':
                    torch.cuda.empty_cache()
                    
            except Exception as e:
                logger.error(f"SegFormer 諛곗튂 異붾줎 以??ㅻ쪟: {e}")
                # ?ㅻ쪟 ??鍮?寃곌낵 異붽? (媛쒖닔 留욎땄)
                for _ in batch:
                    results.append(SegmentationResult(
                        mask=np.zeros((1, 1), dtype=np.uint8), 
                        defect_type="normal",  # fallback to valid DB enum 
                        defect_ratio=0.0
                    ))
                    
        return results

    def _analyze_mask(self, mask: np.ndarray) -> SegmentationResult:
        """留덉뒪??遺꾩꽍?섏뿬 寃고븿 ?좏삎 寃곗젙"""
        total_pixels = mask.size
        
        # 0: Normal, 1: Crack, 2: Soiling
        crack_pixels = np.count_nonzero(mask == 1)
        soiling_pixels = np.count_nonzero(mask == 2)
        
        crack_ratio = crack_pixels / total_pixels
        soiling_ratio = soiling_pixels / total_pixels
        
        # 寃고븿 ?먯젙 (?꾧퀎媛?0.1% - 議곗젙 媛??
        if crack_ratio > 0.001:
            defect_type = "defect" # Crack -> Defect
        elif soiling_ratio > 0.001:
            defect_type = "soiling"
        else:
            defect_type = "normal"
            
        return SegmentationResult(
            mask=mask.astype(np.uint8),
            defect_type=defect_type,
            defect_ratio=max(crack_ratio, soiling_ratio)
        )
