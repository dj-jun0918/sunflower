"""
Solar Eye Backend - FCM (Firebase Cloud Messaging) Module

FCM 푸시 알림 발송 기능 제공
"""

import logging
from typing import Optional

from firebase_admin import messaging

from app.core.firebase import get_firebase_app

logger = logging.getLogger(__name__)


class FCMPayload:
    """FCM 푸시 알림 페이로드 구성"""

    def __init__(
        self,
        title: str,
        body: str,
        image_url: Optional[str] = None,
        deep_link: Optional[str] = None,
        data: Optional[dict] = None,
    ):
        self.title = title
        self.body = body
        self.image_url = image_url
        self.deep_link = deep_link
        self.data = data or {}

    def to_notification(self) -> messaging.Notification:
        """FCM Notification 객체로 변환"""
        return messaging.Notification(
            title=self.title,
            body=self.body,
            image=self.image_url,
        )

    def to_android_config(self) -> messaging.AndroidConfig:
        """Android 전용 설정"""
        android_notification = messaging.AndroidNotification(
            title=self.title,
            body=self.body,
            image=self.image_url,
            click_action="FLUTTER_NOTIFICATION_CLICK",
            priority="high",
            channel_id="solar_eye_alerts",
        )
        return messaging.AndroidConfig(
            priority="high",
            notification=android_notification,
            data=self.data,
        )

    def to_apns_config(self) -> messaging.APNSConfig:
        """iOS 전용 설정"""
        aps = messaging.Aps(
            alert=messaging.ApsAlert(
                title=self.title,
                body=self.body,
            ),
            sound="default",
            badge=1,
            mutable_content=True,
        )
        return messaging.APNSConfig(
            payload=messaging.APNSPayload(aps=aps),
        )

    def to_data_dict(self) -> dict:
        """데이터 페이로드 반환"""
        data = {
            "title": self.title,
            "body": self.body,
            **self.data,
        }
        if self.deep_link:
            data["deep_link"] = self.deep_link
        if self.image_url:
            data["image_url"] = self.image_url
        return data


async def send_push_notification(
    fcm_token: str,
    payload: FCMPayload,
) -> Optional[str]:
    """
    단일 기기에 FCM 푸시 알림 발송

    Args:
        fcm_token: FCM 토큰
        payload: 알림 페이로드

    Returns:
        str: 메시지 ID (성공 시)
        None: 발송 실패 시
    """
    if not get_firebase_app():
        logger.warning("Firebase not initialized. Push notification skipped.")
        return None

    try:
        message = messaging.Message(
            notification=payload.to_notification(),
            android=payload.to_android_config(),
            apns=payload.to_apns_config(),
            data=payload.to_data_dict(),
            token=fcm_token,
        )

        response = messaging.send(message)
        logger.info(f"Push notification sent successfully: {response}")
        return response

    except messaging.UnregisteredError:
        logger.warning(f"FCM token is unregistered: {fcm_token[:20]}...")
        return None
    except messaging.InvalidArgumentError as e:
        logger.error(f"Invalid FCM argument: {e}")
        return None
    except Exception as e:
        logger.error(f"Failed to send push notification: {e}")
        return None


async def send_push_notification_batch(
    fcm_tokens: list[str],
    payload: FCMPayload,
) -> tuple[int, int]:
    """
    여러 기기에 FCM 푸시 알림 일괄 발송

    Args:
        fcm_tokens: FCM 토큰 목록
        payload: 알림 페이로드

    Returns:
        tuple[int, int]: (성공 수, 실패 수)
    """
    if not get_firebase_app():
        logger.warning("Firebase not initialized. Push notifications skipped.")
        return 0, len(fcm_tokens)

    if not fcm_tokens:
        return 0, 0

    try:
        messages = [
            messaging.Message(
                notification=payload.to_notification(),
                android=payload.to_android_config(),
                apns=payload.to_apns_config(),
                data=payload.to_data_dict(),
                token=token,
            )
            for token in fcm_tokens
        ]

        response = messaging.send_all(messages)
        success_count = response.success_count
        failure_count = response.failure_count

        logger.info(
            f"Batch push notification sent: {success_count} success, {failure_count} failed"
        )
        return success_count, failure_count

    except Exception as e:
        logger.error(f"Failed to send batch push notifications: {e}")
        return 0, len(fcm_tokens)


def create_defect_alert_payload(
    panel_name: str,
    defect_type: str,
    confidence: float,
    detection_id: int,
    image_url: Optional[str] = None,
) -> FCMPayload:
    """
    결함/오염 탐지 알림 페이로드 생성

    Args:
        panel_name: 패널 이름
        defect_type: 결함 유형
        confidence: 신뢰도
        detection_id: 탐지 결과 ID
        image_url: 스냅샷 이미지 URL

    Returns:
        FCMPayload
    """
    type_display = {
        "defect": "결함",
        "soiling": "오염",
    }.get(defect_type, defect_type)

    title = f"🔔 {panel_name} {type_display} 감지"
    body = f"{type_display}이(가) {confidence*100:.1f}% 신뢰도로 감지되었습니다."

    return FCMPayload(
        title=title,
        body=body,
        image_url=image_url,
        deep_link=f"solareye://detection/{detection_id}",
        data={
            "type": "detection",
            "detection_id": str(detection_id),
            "defect_type": defect_type,
        },
    )


def create_report_alert_payload(
    panel_name: str,
    report_type: str,  # daily, weekly
    report_date: str,
) -> FCMPayload:
    """
    리포트 생성 알림 페이로드 생성

    Args:
        panel_name: 패널 이름
        report_type: 리포트 유형
        report_date: 리포트 날짜

    Returns:
        FCMPayload
    """
    type_display = "일간" if report_type == "daily" else "주간"
    title = f"📊 {panel_name} {type_display} 리포트"
    body = f"{report_date} {type_display} 리포트가 생성되었습니다."

    return FCMPayload(
        title=title,
        body=body,
        deep_link=f"solareye://report/{report_type}/{report_date}",
        data={
            "type": "report",
            "report_type": report_type,
            "report_date": report_date,
        },
    )


def create_weather_alert_payload(
    panel_name: str,
    weather_status: str,
    message: str,
) -> FCMPayload:
    """
    날씨 관련 알림 페이로드 생성

    Args:
        panel_name: 패널 이름
        weather_status: 날씨 상태
        message: 알림 메시지

    Returns:
        FCMPayload
    """
    title = f"🌧️ {panel_name} 날씨 알림"

    return FCMPayload(
        title=title,
        body=message,
        deep_link=f"solareye://weather",
        data={
            "type": "weather",
            "weather_status": weather_status,
        },
    )
