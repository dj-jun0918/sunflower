"""
Solar Eye Backend - Firebase Admin SDK Integration

Firebase 초기화 및 토큰 검증 기능 제공
"""

import logging
from typing import Optional

import firebase_admin
from firebase_admin import auth, credentials

from app.config import settings

logger = logging.getLogger(__name__)

# Firebase 앱 인스턴스
_firebase_app: Optional[firebase_admin.App] = None


def init_firebase() -> Optional[firebase_admin.App]:
    """
    Firebase Admin SDK 초기화
    
    Returns:
        firebase_admin.App: 초기화된 Firebase 앱 인스턴스
        None: 초기화 실패 시
    """
    global _firebase_app
    
    if _firebase_app is not None:
        return _firebase_app
        
    try:
        # 이미 초기화된 앱이 있는지 확인
        _firebase_app = firebase_admin.get_app()
        logger.info("Firebase app already initialized")
        return _firebase_app
    except ValueError:
        pass  # 앱이 없으면 새로 초기화
    
    try:
        # Firebase 인증 파일이 설정된 경우
        if settings.firebase_credentials_path:
            cred = credentials.Certificate(settings.firebase_credentials_path)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info(f"Firebase initialized with credentials from: {settings.firebase_credentials_path}")
        # 프로젝트 ID만 설정된 경우 (GCP 환경에서 기본 자격증명 사용)
        elif settings.firebase_project_id:
            _firebase_app = firebase_admin.initialize_app(
                options={"projectId": settings.firebase_project_id}
            )
            logger.info(f"Firebase initialized with project ID: {settings.firebase_project_id}")
        else:
            logger.warning("Firebase credentials not configured. Firebase features will be disabled.")
            return None
            
        return _firebase_app
        
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return None


def get_firebase_app() -> Optional[firebase_admin.App]:
    """Firebase 앱 인스턴스 반환"""
    global _firebase_app
    return _firebase_app


def verify_firebase_token(id_token: str) -> Optional[dict]:
    """
    Firebase ID Token 검증
    
    Args:
        id_token: Firebase ID Token
        
    Returns:
        dict: 검증된 토큰 정보 (uid, email, name 등)
        None: 검증 실패 시
    """
    if _firebase_app is None:
        logger.error("Firebase not initialized")
        return None
        
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except auth.ExpiredIdTokenError:
        logger.warning("Firebase token expired")
        return None
    except auth.RevokedIdTokenError:
        logger.warning("Firebase token revoked")
        return None
    except auth.InvalidIdTokenError as e:
        logger.warning(f"Invalid Firebase token: {str(e)}")
        # 디버깅을 위해 상세 내용 출력
        print(f"DEBUG: Invalid token details: {str(e)}")
        return None
    except Exception as e:
        logger.error(f"Firebase token verification failed: {str(e)}")
        print(f"DEBUG: Token verification exception: {type(e).__name__}: {str(e)}")
        return None


def get_firebase_user(uid: str) -> Optional[auth.UserRecord]:
    """
    Firebase UID로 사용자 정보 조회
    
    Args:
        uid: Firebase 사용자 UID
        
    Returns:
        auth.UserRecord: Firebase 사용자 정보
        None: 조회 실패 시
    """
    if _firebase_app is None:
        logger.error("Firebase not initialized")
        return None
        
    try:
        user = auth.get_user(uid)
        return user
    except auth.UserNotFoundError:
        logger.warning(f"Firebase user not found: {uid}")
        return None
    except Exception as e:
        logger.error(f"Failed to get Firebase user: {e}")
        return None


def close_firebase() -> None:
    """Firebase 앱 종료"""
    global _firebase_app
    
    if _firebase_app is not None:
        try:
            firebase_admin.delete_app(_firebase_app)
            _firebase_app = None
            logger.info("Firebase app closed")
        except Exception as e:
            logger.error(f"Failed to close Firebase app: {e}")
