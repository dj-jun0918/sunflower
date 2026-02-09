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
        # 패널 검증 및 자동 생성 로직
        # facility_id가 1이거나 사용자의 소유가 아닌 경우 사용자의 첫 번째 패널을 찾거나 생성함
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
            # 이미지 디코딩 (스냅샷 크롭용)
            nparr = np.frombuffer(image_bytes, np.uint8)
            cv2_image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            analysis_result = await AnalysisService.analyze_image_bytes(
                image_bytes, 
                monitoring_type=monitoring_type
            )
            
            # 4. 결과 저장
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
            
            # 5. 패널 상태 동기화
            # 현재 분석 세션의 탐지 결과들을 바탕으로 패널 상태 업데이트
            stmt = select(Detection).where(Detection.analysis_session_id == session.id)
            res = await db.execute(stmt)
            session_detections = res.scalars().all()
            await AnalysisService._update_panel_status(db, facility_id, session_detections)
            
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
                            logger.info(f"패널 {panel_id}: 알림 전송 완료")
            except Exception as e:
                logger.error(f"알림 전송 중 오류: {e}")
        
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
