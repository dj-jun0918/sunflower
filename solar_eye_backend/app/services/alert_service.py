"""
Solar Eye Backend - Alert Service

알림 관련 비즈니스 로직
"""

import logging
from datetime import datetime
from typing import Optional, Tuple

from sqlalchemy import and_, func, select, update, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.fcm import (
    FCMPayload,
    create_defect_alert_payload,
    send_push_notification,
)
from app.models.alert import Alert, AlertType
from app.models.detection import Detection
from app.models.panel import Panel
from app.models.user import User
from app.schemas.alert import AlertCreate, AlertFilter

logger = logging.getLogger(__name__)


class AlertService:
    """알림 서비스 클래스"""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_alert(
        self,
        data: AlertCreate,
        send_push: bool = True,
    ) -> Alert:
        """
        알림 생성

        Args:
            data: 알림 생성 데이터
            send_push: FCM 푸시 발송 여부

        Returns:
            생성된 Alert 객체
        """
        alert = Alert(
            user_id=data.user_id,
            alert_type=data.alert_type.value,
            title=data.title,
            message=data.message,
            image_url=data.image_url,
            deep_link=data.deep_link,
            detection_id=data.detection_id,
        )
        self.db.add(alert)
        await self.db.commit()
        await self.db.refresh(alert)

        logger.info(f"Alert created: id={alert.id}, type={alert.alert_type}")

        # FCM 푸시 발송
        if send_push:
            await self._send_push_for_alert(alert)

        return alert

    async def create_alert_from_detection(
        self,
        detection: Detection,
        user: User,
        panel: Panel,
    ) -> Optional[Alert]:
        """
        탐지 결과 기반 알림 생성

        Args:
            detection: 탐지 결과
            user: 사용자
            panel: 패널

        Returns:
            생성된 Alert 객체 또는 None (알림이 비활성화된 경우)
        """
        # 사용자 알림 설정 확인
        if not user.notification_enabled:
            logger.debug(f"Notification disabled for user: {user.id}")
            return None

        # 정상 탐지는 알림하지 않음
        if detection.defect_type == "normal":
            logger.debug(f"Alert skipped: normal detection (id={detection.id})")
            return None

        logger.info(f"Creating alert for detection: id={detection.id}, type={detection.defect_type}, conf={detection.confidence}")

        # 알림 유형 결정
        alert_type = AlertType.SOILING if detection.defect_type == "soiling" else AlertType.DEFECT

        # 알림 제목/메시지 생성
        type_display = "오염" if detection.defect_type == "soiling" else "결함"
        title = f"🔔 {panel.name} {type_display} 감지"
        message = f"{type_display}이(가) {detection.confidence*100:.1f}% 신뢰도로 감지되었습니다."

        # 알림 생성
        alert = Alert(
            user_id=user.id,
            detection_id=detection.id,
            alert_type=alert_type.value,
            title=title,
            message=message,
            image_url=detection.snapshot_url,
            deep_link=f"solareye://detection/{detection.id}",
        )
        self.db.add(alert)
        await self.db.commit()
        await self.db.refresh(alert)

        logger.info(f"Detection alert created: alert_id={alert.id}, detection_id={detection.id}")

        # FCM 푸시 발송
        if user.fcm_token:
            payload = create_defect_alert_payload(
                panel_name=panel.name,
                defect_type=detection.defect_type,
                confidence=detection.confidence,
                detection_id=detection.id,
                image_url=detection.snapshot_url,
            )
            await send_push_notification(user.fcm_token, payload)

        return alert

    async def _send_push_for_alert(self, alert: Alert) -> bool:
        """
        알림에 대한 FCM 푸시 발송

        Args:
            alert: 알림 객체

        Returns:
            발송 성공 여부
        """
        # 사용자 조회
        result = await self.db.execute(
            select(User).where(User.id == alert.user_id)
        )
        user = result.scalar_one_or_none()

        if not user or not user.fcm_token:
            logger.debug(f"No FCM token for user: {alert.user_id}")
            return False

        if not user.notification_enabled:
            logger.debug(f"Notification disabled for user: {user.id}")
            return False

        payload = FCMPayload(
            title=alert.title,
            body=alert.message,
            image_url=alert.image_url,
            deep_link=alert.deep_link,
            data={
                "alert_id": str(alert.id),
                "alert_type": alert.alert_type,
            },
        )

        message_id = await send_push_notification(user.fcm_token, payload)
        return message_id is not None

    async def get_alerts(
        self,
        user_id: int,
        filter_params: Optional[AlertFilter] = None,
        offset: int = 0,
        limit: int = 20,
    ) -> Tuple[list[Alert], int, int]:
        """
        알림 목록 조회

        Args:
            user_id: 사용자 ID
            filter_params: 필터 파라미터
            offset: 오프셋
            limit: 제한

        Returns:
            Tuple[list[Alert], int, int]: (알림 목록, 전체 개수, 읽지 않은 개수)
        """
        # 기본 쿼리
        base_query = select(Alert).where(Alert.user_id == user_id)
        count_query = select(func.count(Alert.id)).where(Alert.user_id == user_id)

        # 필터 적용
        if filter_params:
            conditions = []

            if filter_params.alert_type is not None:
                conditions.append(Alert.alert_type == filter_params.alert_type.value)

            if filter_params.is_read is not None:
                conditions.append(Alert.is_read == filter_params.is_read)

            if filter_params.panel_id is not None:
                # 패널 ID로 필터링하려면 detection을 통해 조인 필요
                base_query = base_query.join(
                    Detection, Alert.detection_id == Detection.id, isouter=True
                )
                count_query = count_query.join(
                    Detection, Alert.detection_id == Detection.id, isouter=True
                )
                conditions.append(Detection.panel_id == filter_params.panel_id)

            if conditions:
                base_query = base_query.where(and_(*conditions))
                count_query = count_query.where(and_(*conditions))

        # 정렬 (최신순) 및 페이지네이션
        base_query = (
            base_query
            .options(selectinload(Alert.detection))
            .order_by(Alert.sent_at.desc())
            .offset(offset)
            .limit(limit)
        )

        # 실행
        result = await self.db.execute(base_query)
        alerts = list(result.scalars().all())

        count_result = await self.db.execute(count_query)
        total_count = count_result.scalar() or 0

        # 읽지 않은 알림 개수
        unread_result = await self.db.execute(
            select(func.count(Alert.id))
            .where(Alert.user_id == user_id)
            .where(Alert.is_read == False)  # noqa: E712
        )
        unread_count = unread_result.scalar() or 0

        return alerts, total_count, unread_count

    async def get_alert(
        self,
        alert_id: int,
        user_id: int,
    ) -> Optional[Alert]:
        """
        알림 상세 조회

        Args:
            alert_id: 알림 ID
            user_id: 사용자 ID

        Returns:
            Alert or None
        """
        result = await self.db.execute(
            select(Alert)
            .where(Alert.id == alert_id)
            .where(Alert.user_id == user_id)
            .options(selectinload(Alert.detection))
        )
        return result.scalar_one_or_none()

    async def mark_as_read(
        self,
        alert_id: int,
        user_id: int,
    ) -> Optional[Alert]:
        """
        알림 읽음 처리

        Args:
            alert_id: 알림 ID
            user_id: 사용자 ID

        Returns:
            업데이트된 Alert 또는 None (없는 경우)
        """
        result = await self.db.execute(
            select(Alert)
            .where(Alert.id == alert_id)
            .where(Alert.user_id == user_id)
        )
        alert = result.scalar_one_or_none()

        if not alert:
            return None

        if not alert.is_read:
            alert.is_read = True
            alert.read_at = datetime.utcnow()
            await self.db.commit()
            await self.db.refresh(alert)
            logger.info(f"Alert marked as read: id={alert_id}")

        return alert

    async def mark_all_as_read(self, user_id: int) -> int:
        """
        전체 알림 읽음 처리

        Args:
            user_id: 사용자 ID

        Returns:
            업데이트된 알림 개수
        """
        result = await self.db.execute(
            update(Alert)
            .where(Alert.user_id == user_id)
            .where(Alert.is_read == False)  # noqa: E712
            .values(is_read=True, read_at=datetime.utcnow())
        )
        await self.db.commit()

        updated_count = result.rowcount
        logger.info(f"Marked {updated_count} alerts as read for user: {user_id}")
        return updated_count

    async def get_unread_count(self, user_id: int) -> int:
        """
        읽지 않은 알림 개수 조회

        Args:
            user_id: 사용자 ID

        Returns:
            읽지 않은 알림 개수
        """
        result = await self.db.execute(
            select(func.count(Alert.id))
            .where(Alert.user_id == user_id)
            .where(Alert.is_read == False)  # noqa: E712
        )
        return result.scalar() or 0

    async def delete_alert(
        self,
        alert_id: int,
        user_id: int,
    ) -> bool:
        """
        알림 삭제

        Args:
            alert_id: 알림 ID
            user_id: 사용자 ID

        Returns:
            삭제 성공 여부
        """
        result = await self.db.execute(
            select(Alert)
            .where(Alert.id == alert_id)
            .where(Alert.user_id == user_id)
        )
        alert = result.scalar_one_or_none()

        if not alert:
            return False

        await self.db.delete(alert)
        await self.db.commit()
        logger.info(f"Alert deleted: id={alert_id}")
        return True
