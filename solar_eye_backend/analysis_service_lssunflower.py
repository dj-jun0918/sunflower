"""
Solar Eye Backend - Analysis Service

?대?吏 遺꾩꽍 鍮꾩쫰?덉뒪 濡쒖쭅
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
    """?대?吏 遺꾩꽍 ?쒕퉬??""

    @staticmethod
    async def process_analysis(
        db: AsyncSession,
        facility_id: int,
        image_file: UploadFile,
        monitoring_type: str
    ) -> AnalysisSessionResponse:
        """
        ?대?吏 ?낅줈??諛?遺꾩꽍 ?붿껌 泥섎━
        
        Args:
            db: DB ?몄뀡
            facility_id: ?쒖꽕(?⑤꼸) ID
            image_file: ?낅줈?쒕맂 ?대?吏 ?뚯씪
            monitoring_type: 紐⑤땲?곕쭅 ?좏삎 (cctv/drone)
            
        Returns:
            AnalysisSessionResponse
        """
        # 1. ?대?吏 ???        upload_dir = Path("static/uploads") / datetime.now().strftime("%Y/%m")
        upload_dir.mkdir(parents=True, exist_ok=True)
        
        file_ext = Path(image_file.filename).suffix
        file_name = f"{uuid.uuid4()}{file_ext}"
        file_path = upload_dir / file_name
        
        try:
            with file_path.open("wb") as buffer:
                shutil.copyfileobj(image_file.file, buffer)
        finally:
            image_file.file.close()
            
        # TODO: ?ㅼ젣 諛고룷 ?쒖뿉???꾨찓?몄쓣 ?ы븿???꾩껜 URL濡?蹂寃??꾩슂
        image_url = f"/static/uploads/{datetime.now().strftime('%Y/%m')}/{file_name}"

        # 2. 遺꾩꽍 ?몄뀡 ?앹꽦
        session = AnalysisSession(
            panel_id=facility_id,
            status=AnalysisStatus.PROCESSING,
            type=MonitoringType(monitoring_type),
            original_image_url=image_url
        )
        db.add(session)
        await db.commit()
        await db.refresh(session)
        
        # 3. 鍮꾨룞湲??숆린 遺꾩꽍 ?ㅽ뻾 (?꾩옱???숆린 ?ㅽ뻾)
        try:
            image_bytes = file_path.read_bytes()
            
            # CCTV 遺꾩꽍 ???대?吏 ??μ쓣 ?꾪븳 異붽? 泥섎━
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
            
            # 4. 寃곌낵 ???            saved_ids = []
            for detection in analysis_result.detections:
                 # Save all detections including normal
                if False: # Disable skipping normal detections
                    continue
                
                db_detection = Detection(
                    panel_id=facility_id,
                    analysis_session_id=session.id,  # ?몄뀡 ID ?곌껐
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
            logger.error(f"遺꾩꽍 ?곸꽭 泥섎━ 以??ㅻ쪟 (?몄뀡 ID: {session.id}): {e}")
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
        遺꾩꽍 寃곌낵 議고쉶
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
            
        # Pydantic 紐⑤뜽 ?섎룞 蹂??(detections 蹂?섏쓣 ?꾪빐)
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
        
        # CCTV 遺꾩꽍 寃곌낵 ?대?吏 URL 異붽?
        if session.type.value == "cctv":
            result_dir = Path("static/results") / str(analysis_id)
            if result_dir.exists():
                # Crop ?대?吏 紐⑸줉 (enhanced? mask URL ?ы븿)
                from app.schemas.monitoring import CropImageSchema
                crop_images = []
                for i, det in enumerate(session.detections):
                    enhanced_path = result_dir / f"enhanced_{i}.jpg"
                    mask_path = result_dir / f"mask_{i}.jpg"
                    
                    if enhanced_path.exists() and mask_path.exists():
                        crop_images.append(CropImageSchema(
                            url=f"/static/results/{analysis_id}/enhanced_{i}.jpg",  # Enhanced ?대?吏
                            mask_url=f"/static/results/{analysis_id}/mask_{i}.jpg",  # Mask ?대?吏
                            bbox={"x": det.bbox_x, "y": det.bbox_y, "width": det.bbox_width, "height": det.bbox_height},
                            defect_type=det.defect_type.value,
                            confidence=det.confidence
                        ))
                response.crop_images = crop_images
                
                # 泥?踰덉㎏ ?⑤꼸??????대?吏濡??ㅼ젙 (?섏쐞 ?명솚??
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
        ?쒖꽕 遺꾩꽍 ?대젰 議고쉶
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
        ?대?吏 諛붿씠???곗씠??遺꾩꽍
        """
        try:
            # AI ?뚯씠?꾨씪??濡쒕뱶
            pipeline = get_pipeline()
            
            # ?대?吏 ?붿퐫??            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("?대?吏 ?붿퐫???ㅽ뙣")
            
            logger.info("AI 遺꾩꽍 ?쒖옉")
            
            # AI 遺꾩꽍 ?ㅽ뻾
            results: List[PanelAnalysisResult] = pipeline.analyze(
                image, 
                monitoring_type=monitoring_type
            )
            
            logger.info(f"AI 遺꾩꽍 ?꾨즺! ?⑤꼸 {len(results)}媛??먯?")
            
            # 寃곌낵 吏묎퀎
            normal_count = sum(1 for r in results if r.defect_type == "normal")
            defect_count = sum(1 for r in results if r.defect_type == "defect")
            soiling_count = sum(1 for r in results if r.defect_type == "soiling")
            
            # ?ㅽ궎留?蹂??            detections = []
            import json

            for r in results:
                mask_json = None
                
                # DEBUG PRINT
                print(f"DEBUG: Processing detection. Result mask is None? {r.mask is None}")
                if r.mask is not None:
                     print(f"DEBUG: Mask shape: {r.mask.shape}, Unique: {np.unique(r.mask)}")
                
                # 留덉뒪??泥섎━ (Numpy -> Polygon JSON)
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
            logger.error(f"?대?吏 遺꾩꽍 以??ㅻ쪟: {e}", exc_info=True)
            raise

    @staticmethod
    async def analyze_cctv_with_images(
        image_bytes: bytes,
        session_id: uuid.UUID
    ) -> tuple[AnalysisResultSchema, dict]:
        """
        CCTV ?대?吏 遺꾩꽍 諛?寃곌낵 ?대?吏 ???        
        Returns:
            (AnalysisResultSchema, extra_images_dict)
        """
        try:
            # 湲곕낯 遺꾩꽍 ?섑뻾
            pipeline = get_pipeline()
            
            # ?대?吏 ?붿퐫??            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            if image is None:
                raise ValueError("?대?吏 ?붿퐫???ㅽ뙣")
            
            logger.info("CCTV AI 遺꾩꽍 ?쒖옉 (?대?吏 ????ы븿)")
            
            # 寃곌낵 ????붾젆?좊━ ?앹꽦
            result_dir = Path("static/results") / str(session_id)
            result_dir.mkdir(parents=True, exist_ok=True)
            
            # YOLO Detection
            detections = pipeline.cctv_detector.detect(image)
            logger.info(f"CCTV Detection: {len(detections)} panels")
            
            if not detections:
                # 鍮?寃곌낵 諛섑솚
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
                        
                        # Enhanced ?대?吏 ???(媛??⑤꼸蹂꾨줈)
                        enhanced_path = result_dir / f"enhanced_{i}.jpg"
                        cv2.imwrite(str(enhanced_path), enhanced)
                    except Exception as e:
                        logger.error(f"Enhancement failed for panel {i}: {e}")
                        enhanced_crops.append(cropped)
                        # ?ㅽ뙣 ?쒖뿉???먮낯 ???                        enhanced_path = result_dir / f"enhanced_{i}.jpg"
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
            # L4 GPU 2?? 諛곗튂 ?ъ씠利?8濡??숈떆 泥섎━
            MAX_BATCH_SIZE = 8 
            seg_results = pipeline.seg_classifier.predict_batch(enhanced_crops, batch_size=MAX_BATCH_SIZE)
            
            # 媛??⑤꼸蹂꾨줈 留덉뒪??而щ윭 ?대?吏 ?앹꽦 諛????            for idx, seg_result in enumerate(seg_results):
                if seg_result.mask is not None:
                    mask = seg_result.mask
                    # 留덉뒪?щ? 而щ윭 ?대?吏濡?蹂??(0=珥덈줉, 1=?몃옉, 2=鍮④컯)
                    color_mask = np.zeros((*mask.shape, 3), dtype=np.uint8)
                    color_mask[mask == 0] = [0, 255, 0]  # Normal - Green
                    color_mask[mask == 1] = [0, 255, 255]  # Soiling - Yellow
                    color_mask[mask == 2] = [0, 0, 255]  # Crack - Red
                    
                    mask_path = result_dir / f"mask_{idx}.jpg"
                    cv2.imwrite(str(mask_path), color_mask)
            
            # 寃곌낵 吏묎퀎
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
                    mask=None  # 留덉뒪?щ뒗 ?대?吏濡???ν뻽?쇰?濡?JSON? ?앸왂
                ))
            
            return AnalysisResultSchema(
                total_panels=len(results),
                normal_count=normal_count,
                defect_count=defect_count,
                soiling_count=soiling_count,
                detections=results,
            ), {}
            
        except Exception as e:
            logger.error(f"CCTV ?대?吏 遺꾩꽍 以??ㅻ쪟: {e}", exc_info=True)
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
        ?⑤꼸 ?ㅻ깄??遺꾩꽍 諛?寃곌낵 ???        (湲곗〈 硫붿꽌???좎?)
        """
        # ?⑤꼸 議댁옱 ?뺤씤
        stmt = select(Panel).where(Panel.id == panel_id)
        result = await db.execute(stmt)
        panel = result.scalar_one_or_none()
        
        if not panel:
            raise ValueError(f"?⑤꼸??李얠쓣 ???놁뒿?덈떎: {panel_id}")
        
        # ?대?吏 遺꾩꽍
        analysis_result = await AnalysisService.analyze_image_bytes(
            image_bytes, 
            monitoring_type=monitoring_type
        )
        
        saved_ids = None
        alert_sent = False
        
        # 寃곌낵 ???        if save_results:
            saved_ids = await AnalysisService._save_detections(
                db, panel_id, analysis_result
            )
            logger.info(f"?⑤꼸 {panel_id}: {len(saved_ids)}媛??먯? 寃곌낵 ???)
        
        # ?뚮┝ ?꾩넚 (寃고븿???덈뒗 寃쎌슦)
        if send_alert and (analysis_result.defect_count > 0 or analysis_result.soiling_count > 0):
            try:
                # ?⑤꼸 ?뚯쑀?먯뿉寃??뚮┝
                if panel.user_id and saved_ids:
                    alert_service = AlertService()
                    # 泥?踰덉㎏ 寃고븿 ?먯? 寃곌낵濡??뚮┝ ?앹꽦
                    first_detection_id = saved_ids[0]
                    await alert_service.create_detection_alert(
                        db, first_detection_id, panel.user_id
                    )
                    alert_sent = True
                    logger.info(f"?⑤꼸 {panel_id}: ?뚮┝ ?꾩넚 ?꾨즺")
            except Exception as e:
                logger.error(f"?뚮┝ ?꾩넚 以??ㅻ쪟: {e}")
        
        return analysis_result, saved_ids, alert_sent
    
    @staticmethod
    async def _save_detections(
        db: AsyncSession,
        panel_id: int,
        analysis_result: AnalysisResultSchema,
    ) -> List[int]:
        """
        ?먯? 寃곌낵瑜?DB?????        """
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
