# 🌦️ 날씨 스마트 인사이트 기능 구현 보고서

> **구현 일자**: 2026-01-20  
> **프로젝트**: Solar Eye Backend  

---

## 📋 개요

`weather_implementation_plan_kr.md` 문서에 따라 **스마트 운영 인사이트(Actionable Alerts)** 기능을 구현했습니다. 이 기능은 실시간 날씨와 예보 데이터를 분석하여 태양광 패널 관리자에게 **구체적인 행동 가이드**를 제공합니다.

---

## 🔧 변경된 파일

### 1. [weather.py](file:///c:/Workspace/solar-eye/solar_eye_backend/app/schemas/weather.py) (스키마)

render_diffs(file:///c:/Workspace/solar-eye/solar_eye_backend/app/schemas/weather.py)

**추가된 스키마:**

| 스키마 | 설명 |
|--------|------|
| `InsightType` | 인사이트 타입 Enum (`cleaning`, `maintenance`, `efficiency`, `alert`) |
| `InsightLevel` | 중요도 레벨 Enum (`info`, `warning`, `action_required`) |
| `WeatherInsight` | 개별 인사이트 모델 (타입, 레벨, 메시지, 액션 아이템, 아이콘) |
| `WeatherInsightsResponse` | 인사이트 API 응답 모델 |

---

### 2. [weather_service.py](file:///c:/Workspace/solar-eye/solar_eye_backend/app/services/weather_service.py) (서비스)

render_diffs(file:///c:/Workspace/solar-eye/solar_eye_backend/app/services/weather_service.py)

**추가된 메서드:**

```python
async def analyze_weather_insights(
    self,
    grid_nx: int,
    grid_ny: int,
    panel_id: Optional[int] = None,
) -> dict
```

**구현된 인사이트 분석 로직:**

| 카테고리 | 인사이트 | 조건 |
|----------|----------|------|
| 🧹 청소 | 자연 세척 추천 | 6~48시간 내 비 예보 (강수확률 ≥60%) |
| ❄️ 유지보수 | 제설 작업 알림 | 현재 또는 예보에 눈 발생 |
| ⚡ 효율 | 발전량 저하 경고 | 12시간 이상 흐림/우천 예상 |
| 🌡️ 효율 | 고온 경고 | 기온 ≥35°C |
| 🥶 유지보수 | 동결 주의 | 기온 ≤-5°C |
| 💨 알림 | 강풍 주의 | 풍속 ≥10m/s |

---

### 3. [weather.py](file:///c:/Workspace/solar-eye/solar_eye_backend/app/api/v1/weather.py) (API 라우터)

render_diffs(file:///c:/Workspace/solar-eye/solar_eye_backend/app/api/v1/weather.py)

**추가된 엔드포인트:**

```
GET /api/v1/weather/insights
```

---

## 🚀 API 활용 방법

### 엔드포인트

```
GET /api/v1/weather/insights
```

### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `panelId` | integer | △ | 패널 ID |
| `lat` | float | △ | 위도 (-90 ~ 90) |
| `lng` | float | △ | 경도 (-180 ~ 180) |

> **참고**: `panelId` 또는 `lat/lng` 중 하나는 필수입니다.

### 요청 예시

```bash
# 패널 ID로 조회
curl -X GET "https://api.example.com/api/v1/weather/insights?panelId=1" \
  -H "Authorization: Bearer {access_token}"

# 좌표로 조회
curl -X GET "https://api.example.com/api/v1/weather/insights?lat=37.5665&lng=126.9780" \
  -H "Authorization: Bearer {access_token}"
```

### 응답 예시

```json
{
  "success": true,
  "message": "스마트 관리 인사이트 조회 성공",
  "data": {
    "panelId": 1,
    "location": "서울시 강남구",
    "currentTemperature": 15.5,
    "currentWeatherStatus": "clear",
    "isRaining": false,
    "insights": [
      {
        "type": "cleaning",
        "level": "info",
        "message": "약 12시간 후 비 예보가 있습니다 (강수확률 70%).",
        "actionItem": "오늘 패널 청소는 권장하지 않습니다. 비로 인한 자연 세척 효과가 기대됩니다.",
        "icon": "eco"
      },
      {
        "type": "efficiency",
        "level": "warning",
        "message": "향후 15시간 동안 흐리거나 우천이 예상됩니다.",
        "actionItem": "기상 악화로 인해 오늘 예상 발전량이 평소보다 낮을 수 있습니다.",
        "icon": "cloud_queue"
      }
    ],
    "forecastSummary": "24시간 예보: 비 예보 2건, 흐림 예상 15시간",
    "analyzedAt": "2026-01-20T14:10:00"
  }
}
```

---

## 📊 인사이트 타입 및 레벨 설명

### 인사이트 타입 (`InsightType`)

| 타입 | 설명 | 아이콘 예시 |
|------|------|-------------|
| `cleaning` | 청소 관련 (자연 세척, 청소 권장 등) | `eco`, `water_drop`, `cloud` |
| `maintenance` | 유지보수 관련 (제설, 점검 등) | `ac_unit`, `snowing`, `severe_cold` |
| `efficiency` | 발전 효율 관련 | `cloud_queue`, `thermostat`, `wb_sunny` |
| `alert` | 긴급 알림 (강풍, 시스템 오류 등) | `air`, `cloud_off` |

### 인사이트 레벨 (`InsightLevel`)

| 레벨 | 설명 | UI 표현 권장 |
|------|------|--------------|
| `info` | 참고 정보 | 🔵 파란색 / 일반 텍스트 |
| `warning` | 주의 필요 | 🟡 노란색 / 경고 아이콘 |
| `action_required` | 즉시 조치 필요 | 🔴 빨간색 / 알림 배너 |

---

## 🖥️ 프론트엔드 연동 가이드

### 1. 대시보드 통합

```javascript
// React 예시
const WeatherInsightsWidget = ({ panelId }) => {
  const [insights, setInsights] = useState([]);
  
  useEffect(() => {
    fetchInsights(panelId).then(data => {
      setInsights(data.insights);
    });
  }, [panelId]);
  
  return (
    <div className="insights-widget">
      {insights.map((insight, idx) => (
        <InsightCard 
          key={idx}
          type={insight.type}
          level={insight.level}
          message={insight.message}
          actionItem={insight.actionItem}
          icon={insight.icon}
        />
      ))}
    </div>
  );
};
```

### 2. 알림 배너 예시

```jsx
// action_required 레벨 인사이트는 상단 배너로 표시
{insights
  .filter(i => i.level === 'action_required')
  .map(insight => (
    <AlertBanner 
      type="urgent"
      icon={insight.icon}
      message={insight.message}
      action={insight.actionItem}
    />
  ))
}
```

### 3. 아이콘 매핑 (Material Icons)

응답의 `icon` 필드는 Google Material Icons 이름을 사용합니다:

```javascript
const iconMap = {
  'eco': '🌿',
  'water_drop': '💧',
  'ac_unit': '❄️',
  'cloud_queue': '☁️',
  'thermostat': '🌡️',
  'severe_cold': '🥶',
  'air': '💨',
  'wb_sunny': '☀️',
  'snowing': '🌨️',
  'cloud': '⛅',
  'cloud_off': '📵',
};
```

---

## 🔮 향후 개선 사항

> [!TIP]
> `weather_implementation_plan_kr.md`의 "2단계: 백그라운드 날씨 모니터링" 구현을 위한 추가 개발이 필요합니다.

### 스케줄러 작업 (향후 구현)
- 주기적(1시간마다)으로 모든 활성 패널 지역 날씨 확인
- 우박, 폭설 등 위험 기상 시 푸시 알림 전송

### 알림 정책 결정 필요
- 작은 비소식에도 알림 vs 호우 주의보 급 이상만 알림
- 자동화 수준 (오염 탐지 프로세스 자동 일시 정지 여부)

---

## ✅ 테스트 방법

### 1. 서버 실행

```bash
cd c:\Workspace\solar-eye\solar_eye_backend
uvicorn app.main:app --reload
```

### 2. API 테스트

```bash
# Swagger UI에서 테스트
# http://localhost:8000/docs

# 또는 curl 사용
curl -X GET "http://localhost:8000/api/v1/weather/insights?lat=37.5665&lng=126.9780" \
  -H "Authorization: Bearer {your_token}"
```

---

## 📝 요약

| 항목 | 내용 |
|------|------|
| **새 API** | `GET /api/v1/weather/insights` |
| **새 스키마** | `WeatherInsight`, `WeatherInsightsResponse`, `InsightType`, `InsightLevel` |
| **새 서비스 메서드** | `WeatherService.analyze_weather_insights()` |
| **지원 인사이트** | 자연 세척 추천, 제설 알림, 효율 저하 경고, 기온/풍속 알림 |
