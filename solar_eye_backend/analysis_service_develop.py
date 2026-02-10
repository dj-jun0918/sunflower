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
from app.models.panel import Panel, PanelStatus
from app.models.user import User
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
        user: User,
        facility_id: int,
        image_file: UploadFile,
        monitoring_type: str
    ) -> AnalysisSessionResponse:
        """
        ?대?吏 ?낅줈??諛?遺꾩꽍 ?붿껌 泥섎━
        """
        # ?⑤꼸 寃利?諛??먮룞 ?앹꽦 濡쒖쭅
        # facility_id媛 1?닿굅???ъ슜?먯쓽 ?뚯쑀媛 ?꾨땶 寃쎌슦 ?ъ슜?먯쓽 泥?踰덉㎏ ?⑤꼸??李얘굅???앹꽦??        stmt = select(Panel).where(Panel.id == facility_id, Panel.user_id == user.id)
        res = await db.execute(stmt)
        panel = res.scalar_one_or_none()

        if not panel:
            # ?ъ슜?먯쓽 ?⑤꼸???섎굹?쇰룄 ?덈뒗吏 ?뺤씤
            stmt = select(Panel).where(Panel.user_id == user.id).limit(1)
            res = await db.execute(stmt)
            panel = res.scalar_one_or_none()

            if not panel:
                # ?⑤꼸???놁쑝硫??먮룞 ?앹꽦
                logger.info(f"?ъ슜??{user.id}: ?⑤꼸 遺?щ줈 ?먮룞 ?앹꽦 ?쒖옉")
                panel = Panel(
                    user_id=user.id,
                    name="?섏쓽 泥?踰덉㎏ ?쒖뼇愿??쒖꽕",
                    location="?꾩튂 ?뺣낫 ?놁쓬 (?먮룞 ?앹꽦)",
                    status="active"
                )
                db.add(panel)
                await db.commit()
                await db.refresh(panel)
            
            facility_id = panel.id
            logger.info(f"?ъ슜??{user.id}: 遺꾩꽍 ?곗씠?곕? ?⑤꼸 {facility_id}???좊떦??)

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
            # ?대?吏 ?붿퐫??(?ㅻ깄???щ∼??
            nparr = np.frombuffer(image_bytes, np.uint8)
            cv2_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            analysis_result = await AnalysisService.analyze_image_bytes(
                image_bytes, 
                monitoring_type=monitoring_type
            )
            
            # 4. 寃곌낵 ???            for detection in analysis_result.detections:
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
            
            # 5. ?⑤꼸 ?곹깭 ?숆린??            # ?꾩옱 遺꾩꽍 ?몄뀡???먯? 寃곌낵?ㅼ쓣 諛뷀깢?쇰줈 ?⑤꼸 ?곹깭 ?낅뜲?댄듃
            stmt = select(Detection).where(Detection.analysis_session_id == session.id)
            res = await db.execute(stmt)
            session_detections = res.scalars().all()
            await AnalysisService._update_panel_status(db, facility_id, session_detections)
            
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
            
            # ?대?吏 ?붿퐫??            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            print(f"DEBUG: Image decoded. Shape: {image.shape if image is not None else 'None'}")
            
            if image is None:
                print("DEBUG: Image decoding failed (None)")
                raise ValueError("?대?吏 ?붿퐫???ㅽ뙣")
            
            logger.info("AI 遺꾩꽍 ?쒖옉")
            print("DEBUG: Starting AI Pipeline analysis...")
            
            # AI 遺꾩꽍 ?ㅽ뻾
            results: List[PanelAnalysisResult] = pipeline.analyze(
                image, 
                monitoring_type=monitoring_type
            )
            
            print(f"DEBUG: Analysis completed. Results count: {len(results)}")
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
        CCTV ?대?吏 遺꾩꽍 諛?寃곌낵 ?대?吏 ???(ESRGAN + SegFormer)
        
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
            
            logger.info("CCTV AI 遺꾩꽍 ?쒖옉 (ESRGAN + SegFormer ?대?吏 ????ы븿)")
            
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
            # Decode image for cropping snapshots
            nparr = np.frombuffer(image_bytes, np.uint8)
            image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            
            saved_ids = await AnalysisService._save_detections(
                db, panel_id, analysis_result, original_image=image
            )
            logger.info(f"?⑤꼸 {panel_id}: {len(saved_ids)}媛??먯? 寃곌낵 ???)
        
        # ?뚮┝ ?꾩넚 (寃고븿???덈뒗 寃쎌슦)
        if send_alert and (analysis_result.defect_count > 0 or analysis_result.soiling_count > 0):
            try:
                # ?⑤꼸 ?뚯쑀?먯뿉寃??뚮┝
                if panel.user_id and saved_ids:
                    alert_service = AlertService(db)
                    # Get the first defect detection object
                    stmt = select(Detection).where(Detection.id == saved_ids[0])
                    res = await db.execute(stmt)
                    first_detection = res.scalar_one_or_none()
                    
                    if first_detection:
                        # Get user for FCM token
                        res_user = await db.execute(select(User).where(User.id == panel.user_id))
                        user = res_user.scalar_one_or_none()
                        
                        if user:
                            await alert_service.create_alert_from_detection(
                                detection=first_detection,
                                user=user,
                                panel=panel
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
        original_image: Optional[np.ndarray] = None
    ) -> List[int]:
        """
        ?먯? 寃곌낵瑜?DB?????        """
        saved_ids = []
        
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
        
        # ?⑤꼸 ?곹깭 ?숆린??        await AnalysisService._update_panel_status(db, panel_id, added_detections)
        
        await db.commit()
        
        return saved_ids
    
    @staticmethod
    async def _save_snapshot(
        image: np.ndarray,
        bbox: BoundingBoxSchema,
        defect_type: str
    ) -> str:
        """
        ?먯? 遺?꾨? ?щ∼?섏뿬 ?대?吏 ?뚯씪濡????        """
        try:
            h, w = image.shape[:2]
            
            # BBox 醫뚰몴 (?쎌? ?⑥쐞濡?蹂???꾩슂???섎룄 ?덉쑝???꾩옱 ?ㅽ궎留덇? ?쎌? ?⑥쐞?몄? ?뺤씤 媛??
            # YOLO results usually give absolute pixel coords if we used .xyxy
            # monitoring_screen assumes they are absolute if we draw them directly.
            
            x1 = int(max(0, bbox.x))
            y1 = int(max(0, bbox.y))
            x2 = int(min(w, bbox.x + bbox.width))
            y2 = int(min(h, bbox.y + bbox.height))
            
            # ?덈Т ?묒쑝硫?理쒖냼 ?ш린 ?뺣낫 (?ъ쑀遺?
            padding = 10
            x1 = max(0, x1 - padding)
            y1 = max(0, y1 - padding)
            x2 = min(w, x2 + padding)
            y2 = min(h, y2 + padding)
            
            crop = image[y1:y2, x1:x2]
            
            if crop.size == 0:
                return None
                
            # ?붾젆?좊━ ?앹꽦
            now = datetime.now()
            rel_path = f"snapshots/{now.strftime('%Y/%m/%d')}"
            save_dir = Path("static") / rel_path
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
        ?먯? 寃곌낵瑜?諛뷀깢?쇰줈 ?⑤꼸???곹깭瑜??낅뜲?댄듃?⑸땲??
        """
        if not detections:
            # ?먯? 寃곌낵媛 ?놁쑝硫??뺤긽?쇰줈 媛꾩＜???섎룄 ?덉쑝?? 
            # ?ш린?쒕뒗 紐낆떆?곸쑝濡??먯???寃쎌슦留?泥섎━
            return

        # ?ш컖???쒖쐞: defect(error) > soiling(maintenance) > normal(active)
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
            logger.info(f"?⑤꼸 {panel_id} ?곹깭 ?숆린?? {panel.status} -> {new_status}")
            panel.status = new_status
            await db.flush()
