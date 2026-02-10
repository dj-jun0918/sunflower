"""
Solar Eye Backend - Analysis Service

이미지 분석 비즈니스 로직
"""

import logging
import os
import uuid
import shutil
import asyncio
import json
import torch
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Tuple

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
from app.models.panel import Panel, PanelStatus
from app.models.user import User
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
        user: User,
        facility_id: int,
        image_file: UploadFile,
        monitoring_type: str
    ) -> AnalysisSessionResponse:
        """
        이미지 업로드 및 분석 요청 처리
        """
        # 패널 검증 및 자동 생성 로직 (Original Maintainer logic)
        stmt = select(Panel).where(Panel.id == facility_id, Panel.user_id == user.id)
        res = await db.execute(stmt)
        panel = res.scalar_one_or_none()

        if not panel:
            # 사용자의 패널이 하나라도 있는지 확인
            stmt = select(Panel).where(Panel.user_id == user.id).limit(1)
            res = await db.execute(stmt)
            panel = res.scalar_one_or_none()

            if not panel:
                # 패널이 없으면 자동 생성
                logger.info(f"사용자 {user.id}: 패널 부재로 자동 생성 시작")
                panel = Panel(
                    user_id=user.id,
                    name="나의 첫 번째 태양광 시설",
                    location="위치 정보 없음 (자동 생성)",
                    status="active"
                )
                db.add(panel)
                await db.commit()
                await db.refresh(panel)
            
            facility_id = panel.id
            logger.info(f"사용자 {user.id}: 분석 데이터를 패널 {facility_id}에 할당함")

        # 1. 이미지 저장
        project_root = Path(__file__).resolve().parents[2]
        upload_dir = project_root / "static" / "uploads" / datetime.now().strftime("%Y/%m")
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
        
        # 3. 분석 수행 (CCTV 전용 로직 병합)
        try:
            image_bytes = file_path.read_bytes()
            
            print(f"DEBUG: process_analysis - monitoring_type: '{monitoring_type}'")
            if monitoring_type == "cctv":
                print("DEBUG: Executing analyze_cctv_with_images (CCTV Path)")
                # lssunflower 브랜치의 이미지 생성 포함 분석 로직
                analysis_result, _ = await AnalysisService.analyze_cctv_with_images(
                    image_bytes, 
                    session.id
                )
            else:
                print(f"DEBUG: Executing analyze_image_bytes (General Path for {monitoring_type})")
                # 일반 분석 로직
                analysis_result = await AnalysisService.analyze_image_bytes(
                    image_bytes, 
                    monitoring_type=monitoring_type
                )
            
            # 4. 결과 저장
            # decode image for snapshots
            nparr = np.frombuffer(image_bytes, np.uint8)
            cv2_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            added_detections = []
            for detection in analysis_result.detections:
                # Create snapshot for each detection
                snapshot_url = None
                try:
                    snapshot_url = await AnalysisService._save_snapshot(
                        image=cv2_image,
                        bbox=detection.bbox,
                        defect_type=detection.defect_type
                    )
                except Exception as e:
                    logger.error(f"Snapshot creation failed: {e}")

                db_detection = Detection(
                    panel_id=facility_id,
                    analysis_session_id=session.id,
                    defect_type=detection.defect_type,
                    defect_subtype=detection.defect_subtype,
                    confidence=detection.class_confidence,
                    bbox_x=detection.bbox.x,
                    bbox_y=detection.bbox.y,
                    bbox_width=detection.bbox.width,
                    bbox_height=detection.bbox.height,
                    detected_at=datetime.utcnow(),
                    snapshot_url=snapshot_url,
                    mask=detection.mask
                )
                db.add(db_detection)
                added_detections.append(db_detection)
            
            # 5. 패널 상태 동기화
            # 현재 분석 세션의 탐지 결과들을 바탕으로 패널 상태 업데이트
            await AnalysisService._update_panel_status(db, facility_id, added_detections)
            
            # 6. 알림 전송 (결함이 있는 경우)
            defect_detections = [d for d in added_detections if d.defect_type in [DefectType.DEFECT, DefectType.SOILING]]
            logger.info(f"Analysis complete: {len(added_detections)} detections, {len(defect_detections)} defects/soilings")
            
            if defect_detections:
                try:
                    # Ensure user and panel are ready for alert service
                    await db.refresh(user)
                    await db.refresh(panel)
                    
                    alert_service = AlertService(db)
                    # 시설 소유자에게 알림 (user 객체 사용)
                    # 가장 신뢰도가 높은 결함 하나에 대해 알림 생성
                    best_defect = max(defect_detections, key=lambda d: d.confidence)
                    logger.info(f"Triggering alert for best defect: id={best_defect.id}, type={best_defect.defect_type}, conf={best_defect.confidence}")
                    
                    await alert_service.create_alert_from_detection(
                        detection=best_defect,
                        user=user,
                        panel=panel
                    )
                    logger.info(f"사용자 {user.id}: 결함 감지 자동 알림 생성 성공")
                except Exception as e:
                    logger.error(f"자동 알림 생성 중 오류: {e}", exc_info=True)

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
        분석 결과 조회 (CCTV 상세 이미지 필드 매핑 추가)
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

        print(f"DEBUG: get_analysis_result - session type: {session.type}")
        # CCTV 분석 결과 이미지 URL 추가 (lssunflower 프론트엔드 호환용)
        if session.type == MonitoringType.CCTV:
            project_root = Path(__file__).resolve().parents[2]
            result_dir = project_root / "static" / "results" / str(analysis_id)
            print(f"DEBUG: Checking result_dir: {result_dir.absolute()} (Exists: {result_dir.exists()})")
            if result_dir.exists():
                from app.schemas.monitoring import CropImageSchema
                crop_images = []
                for i, det in enumerate(session.detections):
                    enhanced_path = result_dir / f"enhanced_{i}.jpg"
                    mask_path = result_dir / f"mask_{i}.jpg"
                    
                    if enhanced_path.exists() and mask_path.exists():
                        crop_images.append(CropImageSchema(
                            url=f"/static/results/{analysis_id}/enhanced_{i}.jpg",
                            mask_url=f"/static/results/{analysis_id}/mask_{i}.jpg",
                            bbox={"x": det.bbox_x, "y": det.bbox_y, "width": det.bbox_width, "height": det.bbox_height},
                            defect_type=det.defect_type.value,
                            confidence=det.confidence
                        ))
                    else:
                        print(f"DEBUG: Files missing for panel {i}: {enhanced_path} or {mask_path}")
                        
                response.crop_images = crop_images
                print(f"DEBUG: Found {len(crop_images)} crop images")
                
                if crop_images:
                    response.enhanced_image_url = crop_images[0].url
                    response.mask_image_url = crop_images[0].mask_url
            else:
                print("DEBUG: Result directory not found!")
        
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
            try:
                import psutil
                process = psutil.Process()
                mem_info = process.memory_info()
                print(f"DEBUG: Memory before pipeline load: {mem_info.rss / 1024 / 1024:.2f} MB")
            except ImportError:
                print("DEBUG: psutil not installed, skipping memory log")

            pipeline = get_pipeline()
            
            try:
                if 'process' in locals():
                    mem_info = process.memory_info()
                    print(f"DEBUG: Memory after pipeline load: {mem_info.rss / 1024 / 1024:.2f} MB")
            except: pass
            
            # 이미지 디코딩
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            print(f"DEBUG: Image decoded. Shape: {image.shape if image is not None else 'None'}")
            
            if image is None:
                print("DEBUG: Image decoding failed (None)")
                raise ValueError("이미지 디코딩 실패")
            
            logger.info("AI 분석 시작")
            print("DEBUG: Starting AI Pipeline analysis...")
            
            # AI 분석 실행
            results: List[PanelAnalysisResult] = pipeline.analyze(
                image, 
                monitoring_type=monitoring_type
            )
            
            print(f"DEBUG: Analysis completed. Results count: {len(results)}")
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
        CCTV 이미지 분석 및 결과 이미지 저장 (ESRGAN + SegFormer)
        
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
            
            logger.info("CCTV AI 분석 시작 (ESRGAN + SegFormer 이미지 저장 포함)")
            print("DEBUG: analyze_cctv_with_images started")
            
            # 결과 저장 디렉토리 생성
            # Use absolute path relative to project root to avoid CWD issues
            project_root = Path(__file__).resolve().parents[2]
            result_dir = project_root / "static" / "results" / str(session_id)
            result_dir.mkdir(parents=True, exist_ok=True)
            print(f"DEBUG: Created result dir (absolute): {result_dir.absolute()}")
            
            # --- Heavy Analysis Logic wrapped in Sync Helper ---
            def _run_analysis_sync():
                # 1. YOLO Detection
                detections = pipeline.cctv_detector.detect(image)
                logger.info(f"CCTV Detection: {len(detections)} panels")
                
                if not detections:
                    return [], [], []

                crops = []
                enhanced_crops = []
                valid_indices = []
                
                for i, detection in enumerate(detections):
                    cropped = pipeline._crop_panel(image, detection.bbox)
                    if cropped.shape[0] >= 10 and cropped.shape[1] >= 10:
                        crops.append(cropped)
                        
                        # Real-ESRGAN Optimization: Skip if already large enough (>256px)
                        try:
                            # 256px is usually enough for SegFormer to get good features
                            if cropped.shape[0] < 256 and cropped.shape[1] < 256:
                                enhanced = pipeline.enhancer.enhance(cropped)
                            else:
                                # Skip enhancement for already large crops to save time
                                enhanced = cropped
                            
                            enhanced_crops.append(enhanced)
                            
                            # Enhanced 이미지 저장
                            enhanced_path = result_dir / f"enhanced_{i}.jpg"
                            cv2.imwrite(str(enhanced_path), enhanced)
                        except Exception as e:
                            logger.error(f"Enhancement failed for panel {i}: {e}")
                            enhanced_crops.append(cropped)
                            cv2.imwrite(str(result_dir / f"enhanced_{i}.jpg"), cropped)
                        
                        valid_indices.append(i)
                
                if not enhanced_crops:
                    return AnalysisResultSchema(
                        total_panels=0, normal_count=0, defect_count=0, soiling_count=0, detections=[]
                    ), {}

                # 2. SegFormer Batch Prediction
                MAX_BATCH_SIZE = 8
                seg_results = pipeline.seg_classifier.predict_batch(enhanced_crops, batch_size=MAX_BATCH_SIZE)
                
                # Cleanup CUDA once after batch
                if torch.cuda.is_available():
                    torch.cuda.empty_cache()
                    
                return seg_results, valid_indices, detections

            # Run the heavy sync logic in a separate thread to avoid blocking FastAPI
            seg_results, valid_indices, detections_raw = await asyncio.to_thread(_run_analysis_sync)
            
            # 각 패널별로 마스크 컬러 이미지 생성 및 저장
            for idx, seg_result in enumerate(seg_results):
                mask_path = result_dir / f"mask_{idx}.jpg"
                if seg_result.mask is not None:
                    mask = seg_result.mask
                    # 마스크를 컬러 이미지로 변환 (0=초록, 1=노랑, 2=빨강)
                    color_mask = np.zeros((*mask.shape, 3), dtype=np.uint8)
                    color_mask[mask == 0] = [0, 255, 0]  # Normal - Green
                    color_mask[mask == 1] = [0, 255, 255]  # Soiling - Yellow
                    color_mask[mask == 2] = [0, 0, 255]  # Crack - Red
                    
                    cv2.imwrite(str(mask_path), color_mask)
                    print(f"DEBUG: Saved mask image: {mask_path}")
                else:
                    print(f"DEBUG: No mask for panel {idx}")
            
            # 결과 집계
            results = []
            normal_count = 0
            defect_count = 0
            soiling_count = 0
            
            for i, seg_result in enumerate(seg_results):
                original_idx = valid_indices[i]
                detection = detections_raw[original_idx]
                
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
                    class_confidence=seg_result.confidence, # Changed from defect_ratio to confidence
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
            # Decode image for cropping snapshots
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            saved_ids = await AnalysisService._save_detections(
                db, panel_id, analysis_result, original_image=image
            )
            logger.info(f"패널 {panel_id}: {len(saved_ids)}개 탐지 결과 저장")
        
        # 알림 전송 (결함이 있는 경우)
        if send_alert and (analysis_result.defect_count > 0 or analysis_result.soiling_count > 0):
            try:
                # 패널 소유자에게 알림
                if panel.user_id and saved_ids:
                    alert_service = AlertService(db)
                    
                    # 저장된 탐지 결과들을 가져옴
                    stmt = select(Detection).where(Detection.id.in_(saved_ids))
                    res = await db.execute(stmt)
                    saved_detections = res.scalars().all()
                    
                    # 결함이나 오염인 것들만 필터링
                    defect_detections = [
                        d for d in saved_detections 
                        if d.defect_type in [DefectType.DEFECT, DefectType.SOILING]
                    ]
                    
                    if defect_detections:
                        # 가장 신뢰도가 높은 결함 하나에 대해 알림 생성
                        best_defect = max(defect_detections, key=lambda d: d.confidence)
                        
                        # Get user for FCM token
                        res_user = await db.execute(select(User).where(User.id == panel.user_id))
                        user = res_user.scalar_one_or_none()
                        
                        if user:
                            await alert_service.create_alert_from_detection(
                                detection=best_defect,
                                user=user,
                                panel=panel
                            )
                            alert_sent = True
                            logger.info(f"패널 {panel_id}: 결함 감지 수동 저장 알림 생성 완료")
            except Exception as e:
                logger.error(f"수동 저장 알림 생성 중 오류: {e}")
        
        return analysis_result, saved_ids, alert_sent
    
    @staticmethod
    async def _save_detections(
        db: AsyncSession,
        panel_id: int,
        analysis_result: AnalysisResultSchema,
        original_image: Optional[np.ndarray] = None
    ) -> List[int]:
        """
        탐지 결과를 DB에 저장
        """
        saved_ids = []
        added_detections = []
        
        for detection in analysis_result.detections:
            # Create snapshot if image is provided
            snapshot_url = None
            if original_image is not None:
                try:
                    snapshot_url = await AnalysisService._save_snapshot(
                        image=original_image,
                        bbox=detection.bbox,
                        defect_type=detection.defect_type
                    )
                except Exception as e:
                    logger.error(f"Snapshot creation failed: {e}")

            db_detection = Detection(
                panel_id=panel_id,
                defect_type=detection.defect_type,
                defect_subtype=detection.defect_subtype,
                confidence=detection.class_confidence,
                bbox_x=detection.bbox.x,
                bbox_y=detection.bbox.y,
                bbox_width=detection.bbox.width,
                bbox_height=detection.bbox.height,
                snapshot_url=snapshot_url,
                detected_at=datetime.utcnow(),
                mask=detection.mask,  # Save mask JSON
            )
            
            db.add(db_detection)
            await db.flush()
            saved_ids.append(db_detection.id)
            added_detections.append(db_detection)
        
        # 패널 상태 동기화
        await AnalysisService._update_panel_status(db, panel_id, added_detections)
        
        await db.commit()
        
        return saved_ids
    
    @staticmethod
    async def _save_snapshot(
        image: np.ndarray,
        bbox: BoundingBoxSchema,
        defect_type: str
    ) -> str:
        """
        탐지 부위를 크롭하여 이미지 파일로 저장
        """
        try:
            h, w = image.shape[:2]
            
            # BBox 좌표 (픽셀 단위로 변환 필요할 수도 있으나 현재 스키마가 픽셀 단위인지 확인 가능)
            # YOLO results usually give absolute pixel coords if we used .xyxy
            # monitoring_screen assumes they are absolute if we draw them directly.
            
            x1 = int(max(0, bbox.x))
            y1 = int(max(0, bbox.y))
            x2 = int(min(w, bbox.x + bbox.width))
            y2 = int(min(h, bbox.y + bbox.height))
            
            # 너무 작으면 최소 크기 확보 (여유분)
            padding = 10
            x1 = max(0, x1 - padding)
            y1 = max(0, y1 - padding)
            x2 = min(w, x2 + padding)
            y2 = min(h, y2 + padding)
            
            crop = image[y1:y2, x1:x2]
            
            if crop.size == 0:
                return None
                
            # 디렉토리 생성
            now = datetime.now()
            rel_path = f"snapshots/{now.strftime('%Y/%m/%d')}"
            project_root = Path(__file__).resolve().parents[2]
            save_dir = project_root / "static" / rel_path
            save_dir.mkdir(parents=True, exist_ok=True)
            
            file_name = f"{uuid.uuid4().hex[:12]}_{defect_type}.jpg"
            save_path = save_dir / file_name
            
            cv2.imwrite(str(save_path), crop)
            
            return f"/static/{rel_path}/{file_name}"
        except Exception as e:
            logger.error(f"Error saving snapshot: {e}")
            return None

    @staticmethod
    async def _update_panel_status(
        db: AsyncSession,
        panel_id: int,
        detections: List[Detection]
    ) -> None:
        """
        탐지 결과를 바탕으로 패널의 상태를 업데이트합니다.
        """
        if not detections:
            # 탐지 결과가 없으면 정상으로 간주할 수도 있으나, 
            # 여기서는 명시적으로 탐지된 경우만 처리
            return

        # 심각도 순위: defect(error) > soiling(maintenance) > normal(active)
        new_status = PanelStatus.ACTIVE.value
        
        has_defect = any(d.defect_type == DefectType.DEFECT for d in detections)
        has_soiling = any(d.defect_type == DefectType.SOILING for d in detections)
        
        if has_defect:
            new_status = PanelStatus.ERROR.value
        elif has_soiling:
            new_status = PanelStatus.MAINTENANCE.value
            
        stmt = select(Panel).where(Panel.id == panel_id)
        res = await db.execute(stmt)
        panel = res.scalar_one_or_none()
        
        if panel and panel.status != new_status:
            logger.info(f"패널 {panel_id} 상태 동기화: {panel.status} -> {new_status}")
            panel.status = new_status
            await db.flush()
