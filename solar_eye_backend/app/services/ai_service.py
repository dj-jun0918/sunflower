"""
Solar Eye Backend - AI Service

AI 파이프라인을 활용한 분석 서비스
스냅샷 이미지 분석 및 탐지 결과 저장
"""

import logging
from datetime import datetime
from typing import List, Optional

import cv2
import numpy as np
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai.pipeline import SolarPanelPipeline, PanelAnalysisResult, get_pipeline
from app.models.detection import Detection
from app.schemas.detection import DetectionCreate, DefectType, DefectSubtype

logger = logging.getLogger(__name__)


class AIService:
    """
    AI 분석 서비스
    
    스냅샷 이미지를 분석하고 탐지 결과를 데이터베이스에 저장
    """
    
    def __init__(self, db: AsyncSession, pipeline: Optional[SolarPanelPipeline] = None):
        """
        Args:
            db: 데이터베이스 세션
            pipeline: AI 파이프라인 인스턴스 (None이면 싱글톤 사용)
        """
        self.db = db
        self._pipeline = pipeline
    
    @property
    def pipeline(self) -> SolarPanelPipeline:
        """파이프라인 인스턴스 (lazy loading)"""
        if self._pipeline is None:
            self._pipeline = get_pipeline()
        return self._pipeline
    
    def _map_defect_type(self, class_name: str) -> DefectType:
        """분류 결과를 DefectType enum으로 매핑"""
        mapping = {
            "normal": DefectType.NORMAL,
            "crack": DefectType.DEFECT,
            "soiling": DefectType.SOILING,
        }
        return mapping.get(class_name, DefectType.NORMAL)
    
    def _map_defect_subtype(self, class_name: str) -> Optional[DefectSubtype]:
        """분류 결과를 DefectSubtype enum으로 매핑"""
        mapping = {
            "crack": DefectSubtype.CRACK,
            "soiling": DefectSubtype.DUST,
        }
        return mapping.get(class_name)
    
    async def analyze_image(
        self,
        image_data: bytes,
        panel_id: int,
        frame_number: Optional[int] = None,
        snapshot_url: Optional[str] = None,
    ) -> List[Detection]:
        """
        이미지 분석 및 탐지 결과 저장
        
        Args:
            image_data: 이미지 바이트 데이터
            panel_id: 패널 ID
            frame_number: 프레임 번호 (선택)
            snapshot_url: 스냅샷 URL (선택)
            
        Returns:
            생성된 Detection 객체 리스트
        """
        logger.info(f"이미지 분석 시작 - 패널 ID: {panel_id}")
        
        # 이미지 디코딩
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            raise ValueError("이미지 디코딩 실패")
        
        # 이미지 크기로 면적 계산용
        image_area = image.shape[0] * image.shape[1]
        
        # AI 파이프라인 분석
        analysis_results = self.pipeline.analyze(image)
        
        # 탐지 결과 저장
        detections = []
        for result in analysis_results:
            # 영역 비율 계산
            bbox_area = result.bbox.area
            area_percentage = (bbox_area / image_area) * 100 if image_area > 0 else 0
            
            detection = Detection(
                panel_id=panel_id,
                defect_type=self._map_defect_type(result.raw_class_name).value,
                defect_subtype=self._map_defect_subtype(result.raw_class_name).value 
                    if self._map_defect_subtype(result.raw_class_name) else None,
                confidence=result.class_confidence,
                bbox_x=result.bbox.x,
                bbox_y=result.bbox.y,
                bbox_width=result.bbox.width,
                bbox_height=result.bbox.height,
                snapshot_url=snapshot_url,
                frame_number=frame_number,
                area_percentage=area_percentage,
            )
            
            self.db.add(detection)
            detections.append(detection)
        
        # 커밋
        await self.db.commit()
        
        # 새로고침
        for detection in detections:
            await self.db.refresh(detection)
        
        logger.info(f"분석 완료 - {len(detections)}개 탐지 결과 저장")
        
        return detections
    
    async def analyze_image_no_save(
        self,
        image_data: bytes,
    ) -> List[PanelAnalysisResult]:
        """
        이미지 분석만 수행 (DB 저장 없음)
        
        테스트 또는 미리보기용
        
        Args:
            image_data: 이미지 바이트 데이터
            
        Returns:
            PanelAnalysisResult 리스트
        """
        # 이미지 디코딩
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            raise ValueError("이미지 디코딩 실패")
        
        # AI 파이프라인 분석
        return self.pipeline.analyze(image)
