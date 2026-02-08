# Solar-Eye Backend Phase 4-5 구현 완료 보고서

> **작성일:** 2026.01.17  
> **Phase 4:** Pydantic 스키마 정의  
> **Phase 5:** 인증 API 구현

---

## 📌 Phase 4: Pydantic 스키마 정의

### 4.1 개요

API 요청/응답에 사용할 Pydantic 스키마를 정의했습니다. 모든 스키마는 `app/schemas/` 디렉토리에 위치하며, ORM 모델과의 변환을 지원합니다.

### 4.2 생성된 파일 목록

| 파일명 | 설명 | 주요 스키마 |
|:---|:---|:---|
| `common.py` | 공통 스키마 | SuccessResponse, ErrorResponse, PaginationParams, PaginationMeta |
| `user.py` | 사용자 스키마 | UserCreate, UserResponse, UserUpdate, LoginRequest, FCMTokenRequest |
| `panel.py` | 패널 스키마 | PanelCreate, PanelResponse, PanelDetail, PanelUpdate, PanelStatus |
| `detection.py` | 탐지 스키마 | BoundingBox, DetectionResponse, DetectionDetail, DetectionFilter |
| `alert.py` | 알림 스키마 | AlertResponse, AlertDetail, AlertList, AlertFilter, AlertCreate |
| `report.py` | 리포트 스키마 | DailyReportResponse, WeeklyReportResponse, EconomicReportResponse |
| `weather.py` | 날씨 스키마 | CurrentWeatherResponse, ForecastResponse, WeatherStatus |
| `__init__.py` | 패키지 초기화 | 모든 스키마 export |

---

### 4.3 스키마 상세 설명

#### 4.3.1 공통 스키마 (`common.py`)

```python
# 성공 응답 (제네릭)
class SuccessResponse(BaseModel, Generic[T]):
    success: bool = True
    message: str = "Success"
    data: Optional[T] = None
    timestamp: datetime

# 에러 응답
class ErrorResponse(BaseModel):
    success: bool = False
    message: str
    error_code: Optional[str]
    details: Optional[list[ErrorDetail]]

# 페이지네이션
class PaginationParams(BaseModel):
    page: int = 1           # 페이지 번호 (1부터)
    page_size: int = 20     # 페이지당 항목 수 (최대 100)

class PaginationMeta(BaseModel):
    current_page: int
    page_size: int
    total_items: int
    total_pages: int
    has_next: bool
    has_previous: bool
```

#### 4.3.2 사용자 스키마 (`user.py`)

```python
# 사용자 응답
class UserResponse(BaseModel):
    id: int
    email: EmailStr
    display_name: Optional[str]
    photo_url: Optional[str]
    provider: str               # google, apple, kakao
    notification_enabled: bool
    is_active: bool
    created_at: datetime
    last_login_at: Optional[datetime]

# 로그인 요청
class LoginRequest(BaseModel):
    id_token: str   # Firebase ID Token

# FCM 토큰 등록
class FCMTokenRequest(BaseModel):
    fcm_token: str
```

#### 4.3.3 패널 스키마 (`panel.py`)

```python
class PanelStatus(str, Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    ERROR = "error"
    MAINTENANCE = "maintenance"

class PanelDetail(BaseModel):
    id: int
    user_id: int
    name: str
    description: Optional[str]
    location: Optional[str]
    rtsp_url: Optional[str]
    status: str
    latitude: Optional[float]
    longitude: Optional[float]
    grid_nx: Optional[int]      # 기상청 격자 X
    grid_ny: Optional[int]      # 기상청 격자 Y
    capacity_kw: Optional[float]
    panel_count: Optional[int]
```

#### 4.3.4 탐지 스키마 (`detection.py`)

```python
class DefectType(str, Enum):
    DEFECT = "defect"       # 물리적 결함
    SOILING = "soiling"     # 오염
    NORMAL = "normal"       # 정상

class BoundingBox(BaseModel):
    x: int
    y: int
    width: int
    height: int

class DetectionDetail(BaseModel):
    id: int
    panel_id: int
    defect_type: str
    defect_subtype: Optional[str]
    confidence: float           # 0.0 ~ 1.0
    bbox: BoundingBox
    snapshot_url: Optional[str]
    detected_at: datetime
```

#### 4.3.5 날씨 스키마 (`weather.py`)

```python
class WeatherStatus(str, Enum):
    CLEAR = "clear"
    CLOUDY = "cloudy"
    RAINY = "rainy"
    SNOWY = "snowy"

class CurrentWeatherResponse(BaseModel):
    temperature: float      # 기온 (°C)
    humidity: int           # 습도 (%)
    precipitation: float    # 강수량 (mm)
    weather_status: WeatherStatus
    is_raining: bool
    observed_at: datetime
```

---

## 📌 Phase 5: 인증 API 구현

### 5.1 개요

Firebase Authentication 기반 소셜 로그인 API를 구현했습니다. 프론트엔드에서 Firebase SDK로 로그인 후 받은 ID Token을 백엔드에서 검증하고 사용자를 관리합니다.

### 5.2 생성/수정된 파일

| 파일명 | 설명 |
|:---|:---|
| `app/services/auth_service.py` | 인증 비즈니스 로직 |
| `app/services/__init__.py` | 서비스 패키지 초기화 |
| `app/api/v1/auth.py` | 인증 API 라우터 |
| `app/api/v1/__init__.py` | v1 API 라우터 통합 |
| `app/main.py` | API 라우터 등록 (수정) |

---

### 5.3 인증 서비스 (`auth_service.py`)

```python
class AuthService:
    """인증 서비스"""
    
    async def verify_and_get_or_create_user(
        self, id_token: str
    ) -> Tuple[User, bool]:
        """
        Firebase ID Token 검증 및 사용자 조회/생성
        
        Returns:
            (User, is_new_user): 사용자 객체와 신규 여부
        """
    
    async def update_user(
        self, user: User,
        display_name: Optional[str] = None,
        photo_url: Optional[str] = None,
        notification_enabled: Optional[bool] = None,
    ) -> User:
        """사용자 정보 업데이트"""
    
    async def update_fcm_token(
        self, user: User, fcm_token: str
    ) -> User:
        """FCM 토큰 저장"""
```

---

### 5.4 API 엔드포인트

#### `POST /api/v1/auth/login` - 소셜 로그인

**Request:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "displayName": "홍길동",
      "photoUrl": "https://...",
      "provider": "google",
      "notificationEnabled": true,
      "isActive": true,
      "createdAt": "2026-01-17T10:00:00Z",
      "lastLoginAt": "2026-01-17T10:50:00Z"
    },
    "isNewUser": false
  },
  "timestamp": "2026-01-17T10:50:00Z"
}
```

---

#### `GET /api/v1/auth/me` - 현재 사용자 조회

**Headers:**
```
Authorization: Bearer <Firebase ID Token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "사용자 정보 조회 성공",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "displayName": "홍길동",
    ...
  }
}
```

---

#### `PATCH /api/v1/auth/me` - 사용자 정보 수정

**Request:**
```json
{
  "displayName": "새로운 이름",
  "notificationEnabled": false
}
```

---

#### `POST /api/v1/auth/fcm-token` - FCM 토큰 등록

**Request:**
```json
{
  "fcmToken": "dHJ5X3RoaXNfb25lX291dA..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "FCM 토큰이 등록되었습니다."
}
```

---

### 5.5 인증 플로우 다이어그램

```
┌─────────────┐     1. 소셜 로그인      ┌─────────────────┐
│   Flutter   │ ──────────────────────► │    Firebase     │
│   앱        │ ◄────────────────────── │  Authentication │
└─────────────┘     2. ID Token 반환    └─────────────────┘
       │
       │ 3. POST /api/v1/auth/login
       │    { idToken: "..." }
       ▼
┌─────────────┐     4. 토큰 검증        ┌─────────────────┐
│   FastAPI   │ ──────────────────────► │  Firebase Admin │
│   Backend   │ ◄────────────────────── │      SDK        │
└─────────────┘     5. 검증 결과        └─────────────────┘
       │
       │ 6. 사용자 조회/생성
       ▼
┌─────────────┐
│  PostgreSQL │
│   Database  │
└─────────────┘
```

---

## 📁 디렉토리 구조 (Phase 4-5 이후)

```
solar_eye_backend/
├── app/
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py
│   │   └── v1/                    # [NEW]
│   │       ├── __init__.py        # [NEW] 라우터 통합
│   │       └── auth.py            # [NEW] 인증 API
│   ├── schemas/                   # [UPDATED]
│   │   ├── __init__.py           # [UPDATED] 모든 스키마 export
│   │   ├── common.py             # [NEW] 공통 스키마
│   │   ├── user.py               # [NEW] 사용자 스키마
│   │   ├── panel.py              # [NEW] 패널 스키마
│   │   ├── detection.py          # [NEW] 탐지 스키마
│   │   ├── alert.py              # [NEW] 알림 스키마
│   │   ├── report.py             # [NEW] 리포트 스키마
│   │   └── weather.py            # [NEW] 날씨 스키마
│   ├── services/                  # [UPDATED]
│   │   ├── __init__.py           # [UPDATED]
│   │   └── auth_service.py       # [NEW] 인증 서비스
│   └── main.py                    # [UPDATED] 라우터 등록
```

---

## ✅ 완료 체크리스트

### Phase 4: Pydantic 스키마 정의
- [x] `common.py` - SuccessResponse, ErrorResponse, Pagination
- [x] `user.py` - UserCreate, UserResponse, LoginRequest, FCMTokenRequest
- [x] `panel.py` - PanelCreate, PanelResponse, PanelDetail, PanelStatus
- [x] `detection.py` - DetectionResponse, DetectionDetail, BoundingBox
- [x] `alert.py` - AlertResponse, AlertList, AlertFilter
- [x] `report.py` - DailyReportResponse, WeeklyReportResponse, EconomicReportResponse
- [x] `weather.py` - CurrentWeatherResponse, ForecastResponse, WeatherStatus

### Phase 5: 인증 API 구현
- [x] `AuthService` 클래스 구현
- [x] Firebase 토큰 검증 및 사용자 조회/생성
- [x] 사용자 정보 업데이트
- [x] FCM 토큰 저장
- [x] `POST /api/v1/auth/login` 엔드포인트
- [x] `GET /api/v1/auth/me` 엔드포인트
- [x] `PATCH /api/v1/auth/me` 엔드포인트
- [x] `POST /api/v1/auth/fcm-token` 엔드포인트
- [x] `main.py`에 v1 API 라우터 등록

---

## 📝 다음 단계 (Phase 6)

**패널 API 구현 예정:**
- `GET /api/v1/panels` - 패널 목록 조회
- `POST /api/v1/panels` - 패널 등록
- `GET /api/v1/panels/{id}` - 패널 상세 조회
- `PUT /api/v1/panels/{id}` - 패널 수정
- `DELETE /api/v1/panels/{id}` - 패널 삭제
- `GET /api/v1/panels/{id}/status` - 실시간 상태 조회
