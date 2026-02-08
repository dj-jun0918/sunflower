"""
Solar Eye Backend - AI Engine Module

YOLO + EfficientNet 기반 2단계 AI 파이프라인
- YOLODetector: 패널 영역 탐지
- EfficientNetClassifier: 패널 상태 분류
- SolarPanelPipeline: 통합 파이프라인
- RTSPStreamProcessor: RTSP 스트림 처리
- StreamManager: 다중 스트림 관리
"""

from app.ai.yolo_detector import YOLODetector, DetectionResult, BoundingBox
from app.ai.efficientnet_classifier import EfficientNetClassifier, ClassificationResult
from app.ai.pipeline import SolarPanelPipeline, PanelAnalysisResult, get_pipeline
from app.ai.stream_processor import (
    RTSPStreamProcessor,
    StreamManager,
    StreamConfig,
    StreamStatus,
    FrameData,
    get_stream_manager,
)

__all__ = [
    # YOLO Detector
    "YOLODetector",
    "DetectionResult",
    "BoundingBox",
    # EfficientNet Classifier
    "EfficientNetClassifier",
    "ClassificationResult",
    # Pipeline
    "SolarPanelPipeline",
    "PanelAnalysisResult",
    "get_pipeline",
    # Stream Processor
    "RTSPStreamProcessor",
    "StreamManager",
    "StreamConfig",
    "StreamStatus",
    "FrameData",
    "get_stream_manager",
]

