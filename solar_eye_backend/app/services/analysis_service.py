"""
Solar Eye Backend - Analysis Service

이미지 분석 비즈니스 로직
"""

import logging
import os
import uuid
import shutil
from datetime import datetime
from pathlib import Path
from typing import List, Optional

import cv2
import numpy as np
from PIL import Image
from fastapi import UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.ai import get_pipeline, PanelAnalysisResult
from app.models.analysis import AnalysisSession, AnalysisStatus, MonitoringType
from app.models.detection import Detection, DefectType, DefectSubtype
from app.models.panel import Panel
from app.schemas.analysis import AnalysisResultSchema, PanelDetectionSchema, BoundingBoxSchema
from app.schemas.monitoring import AnalysisSessionResponse, AnalysisResultResponse, AnalysisHistoryResponse
from app.schemas.detection import DetectionResponse
from app.services.alert_service import AlertService

logger = logging.getLogger(__name__)


class AnalysisService:
    """이미지 분석 서비스"""

    @staticmethod
    async def process_analysis(
        db: AsyncSession,
        facility_id: int,
        image_file: UploadFile,
        monitoring_type: str
    ) -> AnalysisSessionResponse:
        """
        이미지 업로드 및 분석 요청 처리
        
        Args:
            db: DB 세션
            facility_id: 시설(패널) ID
            image_file: 업로드된 이미지 파일
            monitoring_type: 모니터링 유형 (cctv/drone)
            
        Returns:
            AnalysisSessionResponse
        """
        # 1. 이미지 저장
        upload_dir = Path("static/uploads") / datetime.now().strftime("%Y/%m")
        upload_dir.mkdir(parents=True, exist_ok=True)
        
        file_ext = Path(image_file.filename).suffix
        file_name = f"{uuid.uuid4()}{file_ext}"
        file_path = upload_dir / file_name
        
        try:
            with file_path.open("wb") as buffer:
                shutil.copyfileobj(image_file.file, buffer)
        finally:
            image_file.file.close()
            
        # TODO: 실제 배포 시에는 도메인을 포함한 전체 URL로 변경 필요
        image_url = f"/static/uploads/{datetime.now().strftime('%Y/%m')}/{file_name}"

        # 2. 분석 세션 생성
        session = AnalysisSession(
            panel_id=facility_id,
            status=AnalysisStatus.PROCESSING,
            type=MonitoringType(monitoring_type),
            original_image_url=image_url
        )
        db.add(session)
        await db.commit()
        await db.refresh(session)
        
        # 3. 비동기/동기 분석 실행 (현재는 동기 실행)
        try:
            image_bytes = file_path.read_bytes()
            
            # CCTV 분석 시 이미지 저장을 위한 추가 처리
            if monitoring_type == "cctv":
                analysis_result, extra_images = await AnalysisService.analyze_cctv_with_images(
                    image_bytes,
                    session.id
                )
            else:
                analysis_result = await AnalysisService.analyze_image_bytes(
                    image_bytes, 
                    monitoring_type=monitoring_type
                )
                extra_images = None
            
            # 4. 결과 저장
            saved_ids = []
            for detection in analysis_result.detections:
                 # Save all detections including normal
                if False: # Disable skipping normal detections
                    continue
                
                db_detection = Detection(
                    panel_id=facility_id,
                    analysis_session_id=session.id,  # 세션 ID 연결
                    defect_type=detection.defect_type,
                    defect_subtype=detection.defect_subtype,
                    confidence=detection.class_confidence,
                    bbox_x=detection.bbox.x,
                    bbox_y=detection.bbox.y,
                    bbox_width=detection.bbox.width,
                    bbox_height=detection.bbox.height,
                    detected_at=datetime.utcnow(),
                )
                db.add(db_detection)
                
            session.status = AnalysisStatus.COMPLETED
            await db.commit()
            
        except Exception as e:
            logger.error(f"분석 상세 처리 중 오류 (세션 ID: {session.id}): {e}")
            session.status = AnalysisStatus.FAILED
            await db.commit()

        await db.refresh(session)
        return AnalysisSessionResponse.model_validate(session)

    @staticmethod
    async def get_analysis_result(
        db: AsyncSession,
        analysis_id: uuid.UUID
    ) -> Optional[AnalysisResultResponse]:
        """
        분석 결과 조회
        """
        stmt = (
            select(AnalysisSession)
            .options(selectinload(AnalysisSession.detections))
            .where(AnalysisSession.id == analysis_id)
        )
        result = await db.execute(stmt)
        session = result.scalar_one_or_none()
        
        if not session:
            return None
            
        # Pydantic 모델 수동 변환 (detections 변환을 위해)
        detection_responses = []
        for d in session.detections:
             detection_responses.append(DetectionResponse(
                 id=d.id,
                 panel_id=d.panel_id,
                 defect_type=d.defect_type,
                 defect_subtype=d.defect_subtype,
                 confidence=d.confidence,
                 bbox=d.bbox,
                 detected_at=d.detected_at,
                 snapshot_url=d.snapshot_url,
                 mask=d.mask  # Include mask JSON
             ))
        
        response = AnalysisResultResponse.model_validate(session)
        response.detections = detection_responses
        
        # CCTV 분석 결과 이미지 URL 추가
        if session.type.value == "cctv":
            result_dir = Path("static/results") / str(analysis_id)
            if result_dir.exists():
                # Crop 이미지 목록 (enhanced와 mask URL 포함)
                from app.schemas.monitoring import CropImageSchema
                crop_images = []
                for i, det in enumerate(session.detections):
                    enhanced_path = result_dir / f"enhanced_{i}.jpg"
                    mask_path = result_dir / f"mask_{i}.jpg"
                    
                    if enhanced_path.exists() and mask_path.exists():
                        crop_images.append(CropImageSchema(
                            url=f"/static/results/{analysis_id}/enhanced_{i}.jpg",  # Enhanced 이미지
                            mask_url=f"/static/results/{analysis_id}/mask_{i}.jpg",  # Mask 이미지
                            bbox={"x": det.bbox_x, "y": det.bbox_y, "width": det.bbox_width, "height": det.bbox_height},
                            defect_type=det.defect_type.value,
                            confidence=det.confidence
                        ))
                response.crop_images = crop_images
                
                # 첫 번째 패널을 대표 이미지로 설정 (하위 호환성)
                if crop_images:
                    response.enhanced_image_url = crop_images[0].url
                    response.mask_image_url = crop_images[0].mask_url
        
        return response

    @staticmethod
    async def get_facility_history(
        db: AsyncSession,
        facility_id: int,
        type: Optional[str] = None
    ) -> List[AnalysisSessionResponse]:
        """
        시설 분석 이력 조회
        """
        query = select(AnalysisSession).where(AnalysisSession.panel_id == facility_id)
        
        if type:
            query = query.where(AnalysisSession.type == MonitoringType(type))
            
        query = query.order_by(AnalysisSession.created_at.desc())
        
        result = await db.execute(query)
        sessions = result.scalars().all()
        
        return [AnalysisSessionResponse.model_validate(s) for s in sessions]
    
    @staticmethod
    async def analyze_image_bytes(
        image_bytes: bytes, 
        monitoring_type: str = "cctv"
    ) -> AnalysisResultSchema:
        """
        이미지 바이트 데이터 분석
        """
        try:
            # AI 파이프라인 로드
            pipeline = get_pipeline()
            
            # 이미지 디코딩
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("이미지 디코딩 실패")
            
            logger.info("AI 분석 시작")
            
            # AI 분석 실행
            results: List[PanelAnalysisResult] = pipeline.analyze(
                image, 
                monitoring_type=monitoring_type
            )
            
            logger.info(f"AI 분석 완료! 패널 {len(results)}개 탐지")
            
            # 결과 집계
            normal_count = sum(1 for r in results if r.defect_type == "normal")
            defect_count = sum(1 for r in results if r.defect_type == "defect")
            soiling_count = sum(1 for r in results if r.defect_type == "soiling")
            
            # 스키마 변환
            detections = []
            import json

            for r in results:
                mask_json = None
                
                # DEBUG PRINT
                print(f"DEBUG: Processing detection. Result mask is None? {r.mask is None}")
                if r.mask is not None:
                     print(f"DEBUG: Mask shape: {r.mask.shape}, Unique: {np.unique(r.mask)}")
                
                # 마스크 처리 (Numpy -> Polygon JSON)
                if r.mask is not None:
                    try:
                        # 1. Resize mask to match original image crop if needed (assuming mask is same size as crop)
                        # The mask from SegFormer is usually 512x512, need to check if it matches detection bbox
                        # For now, let's assume mask is relative to the BBOX.
                        
                        # Convert basic binary mask to contours
                        # mask should be uint8 0 or 255
                        mask_u8 = r.mask.astype(np.uint8)
                        contours, _ = cv2.findContours(mask_u8, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                        
                        print(f"DEBUG: Contours found: {len(contours)}")
                        
                        polygons = []
                        for contour in contours:
                            # Simplify contour
                            epsilon = 0.005 * cv2.arcLength(contour, True)
                            approx = cv2.approxPolyDP(contour, epsilon, True)
                            
                            # Convert to list of [x, y]
                            # Points are relative to the BBOX top-left
                            points = approx.reshape(-1, 2).tolist()
                            if len(points) >= 3: # Valid polygon
                                polygons.append(points)
                        
                        if polygons:
                            mask_json = json.dumps(polygons)
                            print(f"DEBUG: Mask JSON generated! Length: {len(mask_json)}")
                        else:
                            print("DEBUG: No valid polygons generated from contours.")
                            
                    except Exception as e:
                        logger.error(f"Mask conversion failed: {e}")
                        print(f"DEBUG: Mask conversion EXCEPTION: {e}")

                detections.append(PanelDetectionSchema(
                    bbox=BoundingBoxSchema(
                        x=r.bbox.x,
                        y=r.bbox.y,
                        width=r.bbox.width,
                        height=r.bbox.height,
                    ),
                    panel_confidence=r.panel_confidence,
                    defect_type=r.defect_type,
                    defect_subtype=r.defect_subtype,
                    class_confidence=r.class_confidence,
                    raw_class_name=r.raw_class_name,
                    mask=mask_json
                ))
            
            return AnalysisResultSchema(
                total_panels=len(results),
                normal_count=normal_count,
                defect_count=defect_count,
                soiling_count=soiling_count,
                detections=detections,
            )
            
        except Exception as e:
            logger.error(f"이미지 분석 중 오류: {e}", exc_info=True)
            raise

    @staticmethod
    async def analyze_cctv_with_images(
        image_bytes: bytes,
        session_id: uuid.UUID
    ) -> tuple[AnalysisResultSchema, dict]:
        """
        CCTV 이미지 분석 및 결과 이미지 저장
        
        Returns:
            (AnalysisResultSchema, extra_images_dict)
        """
        try:
            # 기본 분석 수행
            pipeline = get_pipeline()
            
            # 이미지 디코딩
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("이미지 디코딩 실패")
            
            logger.info("CCTV AI 분석 시작 (이미지 저장 포함)")
            
            # 결과 저장 디렉토리 생성
            result_dir = Path("static/results") / str(session_id)
            result_dir.mkdir(parents=True, exist_ok=True)
            
            # YOLO Detection
            detections = pipeline.cctv_detector.detect(image)
            logger.info(f"CCTV Detection: {len(detections)} panels")
            
            if not detections:
                # 빈 결과 반환
                return AnalysisResultSchema(
                    total_panels=0,
                    normal_count=0,
                    defect_count=0,
                    soiling_count=0,
                    detections=[],
                ), {}
            
            # Crop & Enhancement
            crops = []
            enhanced_crops = []
            valid_indices = []
            
            for i, detection in enumerate(detections):
                cropped = pipeline._crop_panel(image, detection.bbox)
                if cropped.shape[0] >= 10 and cropped.shape[1] >= 10:
                    crops.append(cropped)
                    
                    # Real-ESRGAN Enhancement
                    try:
                        enhanced = pipeline.enhancer.enhance(cropped)
                        enhanced_crops.append(enhanced)
                        
                        # Enhanced 이미지 저장 (각 패널별로)
                        enhanced_path = result_dir / f"enhanced_{i}.jpg"
                        cv2.imwrite(str(enhanced_path), enhanced)
                    except Exception as e:
                        logger.error(f"Enhancement failed for panel {i}: {e}")
                        enhanced_crops.append(cropped)
                        # 실패 시에도 원본 저장
                        enhanced_path = result_dir / f"enhanced_{i}.jpg"
                        cv2.imwrite(str(enhanced_path), cropped)
                    
                    valid_indices.append(i)
            
            if not enhanced_crops:
                return AnalysisResultSchema(
                    total_panels=0,
                    normal_count=0,
                    defect_count=0,
                    soiling_count=0,
                    detections=[],
                ), {}
            
            # SegFormer Classification
            # L4 GPU 2장: 배치 사이즈 8로 동시 처리
            MAX_BATCH_SIZE = 8 
            seg_results = pipeline.seg_classifier.predict_batch(enhanced_crops, batch_size=MAX_BATCH_SIZE)
            
            # 각 패널별로 마스크 컬러 이미지 생성 및 저장
            for idx, seg_result in enumerate(seg_results):
                if seg_result.mask is not None:
                    mask = seg_result.mask
                    # 마스크를 컬러 이미지로 변환 (0=초록, 1=노랑, 2=빨강)
                    color_mask = np.zeros((*mask.shape, 3), dtype=np.uint8)
                    color_mask[mask == 0] = [0, 255, 0]  # Normal - Green
                    color_mask[mask == 1] = [0, 255, 255]  # Soiling - Yellow
                    color_mask[mask == 2] = [0, 0, 255]  # Crack - Red
                    
                    mask_path = result_dir / f"mask_{idx}.jpg"
                    cv2.imwrite(str(mask_path), color_mask)
            
            # 결과 집계
            results = []
            normal_count = 0
            defect_count = 0
            soiling_count = 0
            
            for i, seg_result in enumerate(seg_results):
                original_idx = valid_indices[i]
                detection = detections[original_idx]
                
                defect_subtype = None
                if seg_result.defect_type == "defect":
                    defect_subtype = "crack"
                    defect_count += 1
                elif seg_result.defect_type == "soiling":
                    defect_subtype = "dust"
                    soiling_count += 1
                else:
                    normal_count += 1
                
                results.append(PanelDetectionSchema(
                    bbox=BoundingBoxSchema(
                        x=detection.bbox.x,
                        y=detection.bbox.y,
                        width=detection.bbox.width,
                        height=detection.bbox.height,
                    ),
                    panel_confidence=detection.confidence,
                    defect_type=seg_result.defect_type,
                    defect_subtype=defect_subtype,
                    class_confidence=seg_result.defect_ratio,
                    raw_class_name=seg_result.defect_type,
                    mask=None  # 마스크는 이미지로 저장했으므로 JSON은 생략
                ))
            
            return AnalysisResultSchema(
                total_panels=len(results),
                normal_count=normal_count,
                defect_count=defect_count,
                soiling_count=soiling_count,
                detections=results,
            ), {}
            
        except Exception as e:
            logger.error(f"CCTV 이미지 분석 중 오류: {e}", exc_info=True)
            raise


    @staticmethod
    async def analyze_panel_snapshot(
        db: AsyncSession,
        panel_id: int,
        image_bytes: bytes,
        monitoring_type: str = "cctv",
        save_results: bool = True,
        send_alert: bool = True,
    ) -> tuple[AnalysisResultSchema, Optional[List[int]], bool]:
        """
        패널 스냅샷 분석 및 결과 저장
        (기존 메서드 유지)
        """
        # 패널 존재 확인
        stmt = select(Panel).where(Panel.id == panel_id)
        result = await db.execute(stmt)
        panel = result.scalar_one_or_none()
        
        if not panel:
            raise ValueError(f"패널을 찾을 수 없습니다: {panel_id}")
        
        # 이미지 분석
        analysis_result = await AnalysisService.analyze_image_bytes(
            image_bytes, 
            monitoring_type=monitoring_type
        )
        
        saved_ids = None
        alert_sent = False
        
        # 결과 저장
        if save_results:
            saved_ids = await AnalysisService._save_detections(
                db, panel_id, analysis_result
            )
            logger.info(f"패널 {panel_id}: {len(saved_ids)}개 탐지 결과 저장")
        
        # 알림 전송 (결함이 있는 경우)
        if send_alert and (analysis_result.defect_count > 0 or analysis_result.soiling_count > 0):
            try:
                # 패널 소유자에게 알림
                if panel.user_id and saved_ids:
                    alert_service = AlertService()
                    # 첫 번째 결함 탐지 결과로 알림 생성
                    first_detection_id = saved_ids[0]
                    await alert_service.create_detection_alert(
                        db, first_detection_id, panel.user_id
                    )
                    alert_sent = True
                    logger.info(f"패널 {panel_id}: 알림 전송 완료")
            except Exception as e:
                logger.error(f"알림 전송 중 오류: {e}")
        
        return analysis_result, saved_ids, alert_sent
    
    @staticmethod
    async def _save_detections(
        db: AsyncSession,
        panel_id: int,
        analysis_result: AnalysisResultSchema,
    ) -> List[int]:
        """
        탐지 결과를 DB에 저장
        """
        saved_ids = []
        
        for detection in analysis_result.detections:
            # Save all detections including normal
            if False: # Disable skipping normal detections
                continue
            
            db_detection = Detection(
                panel_id=panel_id,
                defect_type=detection.defect_type,
                defect_subtype=detection.defect_subtype,
                confidence=detection.class_confidence,
                bbox_x=detection.bbox.x,
                bbox_y=detection.bbox.y,
                bbox_width=detection.bbox.width,
                bbox_height=detection.bbox.height,
                snapshot_url=None,
                detected_at=datetime.utcnow(),
                mask=detection.mask,  # Save mask JSON
            )
            
            db.add(db_detection)
            await db.flush()
            saved_ids.append(db_detection.id)
        
        await db.commit()
        
        return saved_ids
