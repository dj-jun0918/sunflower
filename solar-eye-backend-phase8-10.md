# Solar Eye Backend - Phase 8~10 작업 완료 보고서

> **작업 기간**: 2026.01.18  
> **작업자**: Backend Team  
> **브랜치**: `develop` (feature/alert-api, feature/report-api, feature/weather-api 병합 완료)

---

## 📌 Phase 8: 알림 API 구현 ✅

### 8.1 FCM 모듈 (`app/core/fcm.py`)

Firebase Cloud Messaging을 통한 푸시 알림 발송 기능을 구현했습니다.

| 클래스/함수 | 설명 |
|:---|:---|
| `FCMPayload` | 푸시 알림 페이로드 구성 클래스 (title, body, image, deep_link) |
| `send_push_notification()` | 단일 기기 FCM 푸시 발송 |
| `send_push_notification_batch()` | 다중 기기 일괄 발송 |
| `create_defect_alert_payload()` | 결함/오염 탐지 알림 페이로드 생성 |
| `create_report_alert_payload()` | 리포트 생성 알림 페이로드 생성 |
| `create_weather_alert_payload()` | 날씨 관련 알림 페이로드 생성 |

**주요 기능:**
- Android/iOS 플랫폼별 설정 지원 (AndroidConfig, APNSConfig)
- 알림 유형별 템플릿 메시지 자동 생성
- 딥링크 지원 (`solareye://detection/{id}`)
- 토큰 만료 시 자동 처리 (UnregisteredError)

---

### 8.2 알림 서비스 (`app/services/alert_service.py`)

알림 관련 비즈니스 로직을 담당하는 서비스 클래스입니다.

| 메서드 | 설명 |
|:---|:---|
| `create_alert()` | 알림 생성 및 FCM 푸시 발송 |
| `create_alert_from_detection()` | 탐지 결과 기반 자동 알림 생성 |
| `get_alerts()` | 알림 목록 조회 (필터링, 페이지네이션) |
| `get_alert()` | 알림 상세 조회 |
| `mark_as_read()` | 알림 읽음 처리 |
| `mark_all_as_read()` | 전체 알림 읽음 처리 |
| `get_unread_count()` | 읽지 않은 알림 개수 조회 |
| `delete_alert()` | 알림 삭제 |

**주요 기능:**
- 사용자별 알림 설정 확인 (notification_enabled)
- 정상 탐지(normal)는 알림 제외
- 알림 유형: DEFECT, SOILING, REPORT, SYSTEM, WEATHER

---

### 8.3 알림 API 라우터 (`app/api/v1/alerts.py`)

| 엔드포인트 | 메서드 | 설명 |
|:---|:---:|:---|
| `/api/v1/alerts` | GET | 알림 목록 조회 |
| `/api/v1/alerts/{id}` | GET | 알림 상세 조회 |
| `/api/v1/alerts/{id}/read` | PUT | 알림 읽음 처리 |
| `/api/v1/alerts/read-all` | PUT | 전체 알림 읽음 처리 |
| `/api/v1/alerts/unread/count` | GET | 읽지 않은 알림 개수 |

**필터 파라미터:**
- `alertType`: 알림 유형 (defect/soiling/report/system/weather)
- `isRead`: 읽음 여부 (true/false)
- `panelId`: 패널 ID

---

## 📌 Phase 9: 리포트 API 구현 ✅

### 9.1 리포트 서비스 (`app/services/report_service.py`)

일간/주간 리포트 생성 및 경제성 분석 로직을 구현했습니다.

| 메서드 | 설명 |
|:---|:---|
| `get_daily_report()` | 일간 리포트 조회 |
| `get_or_create_daily_report()` | 일간 리포트 조회 또는 자동 생성 |
| `get_weekly_report()` | 주간 리포트 조회 (7일 트렌드) |
| `get_economic_report()` | 경제성 분석 리포트 |
| `get_daily_reports()` | 일간 리포트 목록 조회 |

**경제성 분석 상수:**
```python
ELECTRICITY_PRICE_KRW = 120.0        # 전력 판매 단가 (원/kWh)
DEFAULT_PANEL_CAPACITY_KW = 5.0      # 패널 용량 (kW)
DAILY_GENERATION_HOURS = 3.5         # 일일 평균 발전 시간
SOILING_EFFICIENCY_LOSS_RATIO = 0.7  # 오염 면적 1%당 효율 손실 0.7%
CLEANING_COST_PER_PANEL = 30000      # 청소 비용 (원/패널)
CLEANING_RECOMMENDED_THRESHOLD = 15.0 # 청소 권고 기준 오염 면적 (%)
```

**경제성 분석 계산 로직:**
1. 효율 손실 = 오염 면적(%) × 0.7
2. 일일 발전 손실 = 용량(kW) × 발전시간(h) × 효율손실(%)
3. 일일 손실 금액 = 발전 손실(kWh) × 전력 단가(원)
4. 손익 분기점 = 청소 비용 ÷ 일일 손실 금액

**청소 권고 조건 (OR):**
- 오염 면적 ≥ 15%
- 일일 손실 금액 ≥ 3,000원
- 손익 분기점 ≤ 30일

---

### 9.2 리포트 API 라우터 (`app/api/v1/reports.py`)

| 엔드포인트 | 메서드 | 설명 |
|:---|:---:|:---|
| `/api/v1/reports/daily` | GET | 일간 리포트 조회 (자동 생성) |
| `/api/v1/reports/daily/list` | GET | 일간 리포트 목록 |
| `/api/v1/reports/weekly` | GET | 주간 리포트 (7일 트렌드) |
| `/api/v1/reports/economic` | GET | 경제성 분석 |

**응답 예시 (경제성 분석):**
```json
{
  "panelId": 1,
  "panelName": "옥상 패널 A",
  "soilingAreaPercent": 18.5,
  "efficiencyLossPercent": 12.95,
  "dailyLossKwh": 2.27,
  "dailyLossKrw": 272,
  "monthlyLossKrw": 8160,
  "cleaningRecommended": true,
  "recommendationReason": "오염 면적이 18.5%로 권고 기준(15%)을 초과했습니다.",
  "breakEvenDays": 110,
  "summaryMessage": "🔔 청소를 권장합니다. 현재 추정 월간 손실은 8,160원입니다."
}
```

---

## 📌 Phase 10: 날씨 API 구현 ✅ (1차 발표 필수)

### 10.1 날씨 서비스 (`app/services/weather_service.py`)

기상청 공공데이터 API 연동 서비스입니다.

| 함수/메서드 | 설명 |
|:---|:---|
| `convert_lat_lon_to_grid()` | 위경도 → 기상청 격자 좌표 변환 (LCC 투영법) |
| `get_base_datetime_for_ultra_srt_ncst()` | 초단기실황 기준 시간 계산 |
| `get_base_datetime_for_vilage_fcst()` | 단기예보 기준 시간 계산 |
| `WeatherService.get_ultra_srt_ncst()` | 초단기실황 조회 |
| `WeatherService.get_vilage_fcst()` | 단기예보 조회 |
| `WeatherService.check_rain_status()` | 우천 여부 확인 |

**기상청 API 연동:**
- `getUltraSrtNcst`: 초단기실황 (매시 40분 이후 제공)
- `getVilageFcst`: 단기예보 (0200, 0500, 0800, 1100, 1400, 1700, 2000, 2300 발표)

**위경도 → 격자 변환 예시:**
```python
convert_lat_lon_to_grid(37.5665, 126.9780)  # 서울 → (60, 127)
```

**Redis 캐싱:**
- 캐시 키: `weather:current:{panel_id}`, `weather:forecast:{panel_id}`
- TTL: 1시간 (3600초)

**Mock 데이터:**
API 키 미설정 시 테스트용 Mock 데이터 반환 (맑음, 15.5°C)

---

### 10.2 날씨 API 라우터 (`app/api/v1/weather.py`)

| 엔드포인트 | 메서드 | 설명 |
|:---|:---:|:---|
| `/api/v1/weather/current` | GET | 현재 날씨 조회 |
| `/api/v1/weather/forecast` | GET | 단기 예보 (24시간, 3시간 단위) |
| `/api/v1/weather/status` | GET | 우천 여부 확인 |

**파라미터:**
- `panelId`: 패널 ID (패널 위치 기반 조회)
- `lat`, `lng`: 위도/경도 (직접 좌표 지정)

**우천 시 알림 스킵 로직:**
- 현재 비가 오는 경우 → `shouldSkipAlert: true`
- 3시간 이내 비 예보 또는 강수확률 ≥ 60% → `shouldSkipAlert: true`

---

## 🔧 환경 설정 필요 사항

### `.env` 파일에 추가 필요한 키

```env
# Firebase (인증, FCM 푸시 알림)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CREDENTIALS_PATH=path/to/firebase-credentials.json

# 기상청 API (날씨 조회)
WEATHER_API_KEY=your-weather-api-key
```

### 키 발급 방법

| 서비스 | 발급처 | 용도 |
|:---|:---|:---|
| Firebase | [Firebase Console](https://console.firebase.google.com) | 인증, FCM 푸시 |
| 기상청 API | [공공데이터포털](https://www.data.go.kr) | 날씨 정보 |

---

## 📁 생성된 파일 목록

### API 라우터 (`app/api/v1/`)
- `alerts.py` - 알림 API (247 lines)
- `reports.py` - 리포트 API (321 lines)
- `weather.py` - 날씨 API (290 lines)

### 서비스 (`app/services/`)
- `alert_service.py` - 알림 서비스 (370 lines)
- `report_service.py` - 리포트 서비스 (528 lines)
- `weather_service.py` - 날씨 서비스 (562 lines)

### 코어 (`app/core/`)
- `fcm.py` - FCM 푸시 알림 모듈 (277 lines)

---

## ✅ 마일스톤 진행 현황

### 1차 발표 필수 항목 (6/8 완료)
- [x] 프로젝트 구조 완성
- [x] DB 모델 및 마이그레이션
- [x] Firebase 인증 연동
- [x] 인증 API (login, me, fcm-token)
- [x] 패널 API (CRUD, status)
- [x] 날씨 API (기상청 연동)
- [ ] Docker Compose 기본 동작
- [ ] Swagger 문서 확인

### 최종 발표 항목 (3/8 완료)
- [x] FCM 푸시 알림
- [x] 경제성 분석 리포트
- [x] 우천 시 알림 중지 기능
- [ ] 모든 API 엔드포인트 구현
- [ ] AI 파이프라인 통합
- [ ] RTSP 스트림 처리
- [ ] 통합 테스트 완료
- [ ] GCP 배포 완료

---

## 🔗 Git 커밋 히스토리

```
5fd6472 phase 10: 날씨 api 작업 완료
b465fbc phase 9: 리포트 api 구현완료
[이전 커밋] phase 8: 알림 api 구현완료
```

**브랜치:**
- `feature/alert-api` → `develop` (merged)
- `feature/report-api` → `develop` (merged)
- `feature/weather-api` → `develop` (merged)
