
import asyncio
import logging
from sqlalchemy import select
from app.db.session import async_session_factory
from app.services.alert_service import AlertService
from app.models.user import User
from app.models.alert import Alert
from app.schemas.alert import AlertCreate, AlertType
from app.core.firebase import init_firebase
from unittest.mock import patch

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def verify_alarm_system():
    print("Starting Alarm System Verification (ORM Mode)...")
    
    # 1. Initialize Firebase
    init_firebase()
    
    async with async_session_factory() as db:
        # 2. Setup Test User
        print("Setting up test user...")
        
        test_email = "verify_alarm@test.com"
        
        # Check if user exists using ORM
        stmt = select(User).where(User.email == test_email)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user:
            print("   Creating local dummy user...")
            # Create user object with CORRECT fields
            user = User(
                firebase_uid="dummy_uid_12345",  # Required field
                email=test_email,
                display_name="Test User",        # Was full_name
                is_active=True,
                # is_superuser=False,             # Removed: not in model
                # hashed_password="dummy",        # Removed: not in model
                fcm_token="dummy_fcm_token_123",
                notification_enabled=True,
                provider="google"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            
        print(f"   Target User ID: {user.id}")
        
        # 3. Simulate Alert Trigger
        print("Triggering test alert...")
        alert_service = AlertService(db)
        
        alert_data = AlertCreate(
            user_id=user.id,
            alert_type=AlertType.SYSTEM,
            title="Verification Test Alert",
            message="This is a test alert to verify the backend logic.",
            deep_link="solareye://test",
            detection_id=None
        )
        
        # Mock the send_push_notification
        with patch('app.services.alert_service.send_push_notification') as mock_send:
            mock_send.return_value = "projects/solar-eye/messages/test-msg-id"
            
            # Create Alert
            alert = await alert_service.create_alert(alert_data)
            
            print(f"   Alert Created: ID {alert.id}")
            
            # 4. Verify DB Insert
            stmt = select(Alert).where(Alert.id == alert.id)
            result = await db.execute(stmt)
            saved_alert = result.scalar_one_or_none()
            
            if saved_alert:
                print("[PASS] Alert successfully saved to database.")
            else:
                print("[FAIL] Alert not found in database.")
                
            # 5. Verify Push Logic Triggered
            if mock_send.called:
                print("[PASS] Push notification send logic was triggered.")
                print(f"   Call args: {mock_send.call_args}")
            else:
                print("[FAIL] Push notification logic was NOT triggered.")

if __name__ == "__main__":
    asyncio.run(verify_alarm_system())
