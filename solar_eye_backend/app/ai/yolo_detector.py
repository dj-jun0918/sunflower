"""
Solar Eye Backend - YOLO Detector (ONNX & Pickle Support)

YOLO 모델을 사용한 태양광 패널 영역 탐지
ONNX Runtime (CPU) 또는 Pickle 로드 모델(Ultralytics) 지원
"""

import logging
import pickle
from dataclasses import dataclass
from pathlib import Path
from typing import Any, List, Optional, Tuple, Union

import cv2
import numpy as np

# Joblib import attempt
try:
    import joblib
except ImportError:
    joblib = None

# ONNX Runtime import attempt
try:
    import onnxruntime as ort
except ImportError:
    ort = None

logger = logging.getLogger(__name__)


@dataclass
class BoundingBox:
    """바운딩 박스 데이터 클래스"""
    x: int
    y: int
    width: int
    height: int
    
    @property
    def x2(self) -> int:
        return self.x + self.width
    
    @property
    def y2(self) -> int:
        return self.y + self.height
    
    @property
    def area(self) -> int:
        return self.width * self.height
    
    @property
    def center(self) -> Tuple[int, int]:
        return (self.x + self.width // 2, self.y + self.height // 2)


@dataclass
class DetectionResult:
    """YOLO 탐지 결과 데이터 클래스"""
    bbox: BoundingBox
    confidence: float
    class_id: int
    class_name: str


class YOLODetector:
    """
    YOLO 기반 패널 탐지기
    
    지원 포맷:
    1. .onnx: ONNX Runtime 사용 (CPU)
    2. .pkl: Joblib/Pickle 로드 (Ultralytics YOLO 객체 등)
    """
    
    INPUT_SIZE = 1024
    
    def __init__(
        self, 
        model_path: str,
        conf_threshold: float = 0.5,
        iou_threshold: float = 0.45,
    ):
        self.model_path = Path(model_path)
        self.conf_threshold = conf_threshold
        self.iou_threshold = iou_threshold
        self.model_type = "unknown"
        self.session = None  # ONNX Session
        self.model = None    # Pickle Model
        
        if not self.model_path.exists():
            # 파일이 없어도 경로가 설정되어 있으면 진행 (나중에 로드 시도)
            logger.warning(f"모델 파일을 찾을 수 없습니다: {model_path}")
        
        self._load_model()
        
    def _load_model(self):
        """모델 파일 확장자에 따라 로드"""
        suffix = self.model_path.suffix.lower()
        if suffix == ".onnx":
            self._load_onnx()
        elif suffix == ".pkl":
            self._load_pickle()
        elif suffix == ".pt":
            self._load_pt()
        else:
            logger.warning(f"알 수 없는 모델 확장자: {suffix}. 기본적으로 Pickle 로드 시도.")
            self._load_pickle()

    def _load_onnx(self):
        if ort is None:
            raise ImportError("onnxruntime이 설치되지 않았습니다.")
        
        logger.info(f"YOLO ONNX 모델 로드 중: {self.model_path}")
        self.session = ort.InferenceSession(
            str(self.model_path),
            providers=["CPUExecutionProvider"]
        )
        self.input_name = self.session.get_inputs()[0].name
        self.output_names = [o.name for o in self.session.get_outputs()]
        self.model_type = "onnx"
        logger.info("YOLO ONNX 모델 로드 완료")

    def _load_pickle(self):
        if not self.model_path.exists():
            return

        logger.info(f"YOLO Pickle 모델 로드 중: {self.model_path}")
        try:
            if joblib:
                self.model = joblib.load(self.model_path)
            else:
                with open(self.model_path, 'rb') as f:
                    self.model = pickle.load(f)
            
            self.model_type = "pickle"
            logger.info("YOLO Pickle 모델 로드 완료")
            
        except Exception as e:
            logger.error(f"Pickle 모델 로드 실패: {e}")
            raise e

    def _load_pt(self):
        """Ultralytics .pt 모델 로드"""
        if not self.model_path.exists():
            return
            
        try:
            from ultralytics import YOLO
            logger.info(f"YOLO PT 모델 로드 중: {self.model_path}")
            self.model = YOLO(str(self.model_path))
            self.model_type = "pt"
            logger.info("YOLO PT 모델 로드 완료")
        except ImportError:
            raise ImportError("ultralytics가 설치되지 않았습니다. `pip install ultralytics` 필요")
        except Exception as e:
            logger.error(f"PT 모델 로드 실패: {e}")
            raise e

    def detect(self, image: np.ndarray) -> List[DetectionResult]:
        """이미지에서 패널 탐지"""
        if self.model_type == "onnx":
            return self._detect_onnx(image)
        elif self.model_type in ["pickle", "pt"]:
            return self._detect_ultralytics(image)
        else:
            # 모델 파일이 없었던 경우 등
            logger.error("모델이 로드되지 않은 상태에서 detect 호출됨")
            return []

    def _detect_ultralytics(self, image: np.ndarray) -> List[DetectionResult]:
        """Ultralytics YOLO (Pickle/PT) 추론"""
        if self.model is None:
             raise RuntimeError("YOLO 모델이 로드되지 않았습니다.")

        # BGR -> RGB 변환 (Ultralytics 모델은 RGB 입력을 기대함)
        if image.shape[2] == 3:
            image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        else:
            image_rgb = image

        # Ultralytics YOLO 추론
        results = self.model(
            image_rgb, 
            conf=self.conf_threshold, 
            iou=self.iou_threshold, 
            imgsz=self.INPUT_SIZE,
            verbose=False
        )
        
        detection_results = []
        
        if results and len(results) > 0:
            r = results[0]
            boxes = r.boxes
            
            for box in boxes:
                # box.xyxy: [x1, y1, x2, y2]
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy().astype(int)
                conf = float(box.conf[0].cpu().numpy())
                cls = int(box.cls[0].cpu().numpy())
                
                # BoundingBox 생성
                w = x2 - x1
                h = y2 - y1
                bbox = BoundingBox(x=x1, y=y1, width=w, height=h)
                
                detection_results.append(DetectionResult(
                    bbox=bbox,
                    confidence=conf,
                    class_id=cls,
                    class_name=r.names[cls] if hasattr(r, 'names') else str(cls)
                ))
                
        return detection_results

    # ... (기존 ONNX _preprocess, _postprocess, _detect_onnx 로직 유지) ...
    
    def _detect_onnx(self, image: np.ndarray) -> List[DetectionResult]:
        """ONNX 모델 추론 (기존 detect 로직)"""
        original_height, original_width = image.shape[:2]
        
        # 전처리
        input_tensor, scale, padding = self._preprocess(image)
        
        # 추론
        outputs = self.session.run(self.output_names, {self.input_name: input_tensor})
        
        # 후처리
        results = self._postprocess(
            outputs[0] if isinstance(outputs, list) else outputs,
            scale,
            padding,
            (original_width, original_height)
        )
        return results

    def _preprocess(self, image: np.ndarray) -> Tuple[np.ndarray, float, Tuple[int, int]]:
        """ONNX 전처리"""
        original_height, original_width = image.shape[:2]
        scale = min(self.INPUT_SIZE / original_width, self.INPUT_SIZE / original_height)
        new_width = int(original_width * scale)
        new_height = int(original_height * scale)
        resized = cv2.resize(image, (new_width, new_height))
        padded = np.full((self.INPUT_SIZE, self.INPUT_SIZE, 3), 114, dtype=np.uint8)
        pad_x = (self.INPUT_SIZE - new_width) // 2
        pad_y = (self.INPUT_SIZE - new_height) // 2
        padded[pad_y:pad_y+new_height, pad_x:pad_x+new_width] = resized
        input_tensor = padded[:, :, ::-1].transpose(2, 0, 1).astype(np.float32) / 255.0
        input_tensor = np.expand_dims(input_tensor, axis=0)
        return input_tensor, scale, (pad_x, pad_y)

    def _postprocess(self, outputs: np.ndarray, scale: float, padding: Tuple[int, int], original_size: Tuple[int, int]) -> List[DetectionResult]:
        """ONNX 후처리"""
        predictions = outputs
        if len(predictions.shape) == 3: predictions = predictions[0]
        if len(predictions.shape) == 2 and predictions.shape[0] < predictions.shape[1]: predictions = predictions.transpose(1, 0)
        
        boxes, scores, class_ids = [], [], []
        for pred in predictions:
            if len(pred) < 5: continue
            x_center, y_center, w, h = pred[:4]
            class_scores = pred[4:]
            class_id = np.argmax(class_scores)
            confidence = class_scores[class_id]
            if confidence < self.conf_threshold: continue
            
            pad_x, pad_y = padding
            x_center = (x_center - pad_x) / scale
            y_center = (y_center - pad_y) / scale
            w, h = w / scale, h / scale
            x1, y1 = int(x_center - w/2), int(y_center - h/2)
            x2, y2 = int(x_center + w/2), int(y_center + h/2)
            
            orig_w, orig_h = original_size
            x1 = max(0, min(x1, orig_w))
            y1 = max(0, min(y1, orig_h))
            x2 = max(0, min(x2, orig_w))
            y2 = max(0, min(y2, orig_h))
            
            boxes.append([x1, y1, x2 - x1, y2 - y1])
            scores.append(float(confidence))
            class_ids.append(int(class_id))

        if not boxes: return []
        
        indices = cv2.dnn.NMSBoxes(boxes, scores, self.conf_threshold, self.iou_threshold)
        results = []
        for i in indices:
            idx = i[0] if isinstance(i, (list, np.ndarray)) else i
            x, y, w, h = boxes[idx]
            results.append(DetectionResult(
                bbox=BoundingBox(x=x, y=y, width=w, height=h),
                confidence=scores[idx],
                class_id=class_ids[idx],
                class_name=f"panel_{class_ids[idx]}"
            ))
        return results

    def detect_from_file(self, image_path: str) -> List[DetectionResult]:
        """파일에서 이미지 로드 후 탐지"""
        image = cv2.imread(image_path)
        if image is None: raise ValueError(f"이미지를 로드할 수 없습니다: {image_path}")
        return self.detect(image)
