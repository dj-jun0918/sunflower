from app.main import app
from app.api.deps import get_current_user
from app.models.user import User

# Mock User for Auth
async def override_get_current_user():
    return User(id=1, email="test@example.com", firebase_uid="test_uid", display_name="Test User")

app.dependency_overrides[get_current_user] = override_get_current_user
