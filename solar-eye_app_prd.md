# [PRD] Solar-Eye: AI 기반 태양광 패널 결함 탐지 및 유지보수 솔루션

| 문서 정보 | 내용 |
| :--- | :--- |
| **프로젝트명** | Solar-Eye (솔라아이) |
| **버전** | v1.3 (MVP Focus) |
| **작성일** | 2026. 01. 15 |
| **작성자** | Solar-Eye Team |
| **상태** | **개발 착수 (In Development)** |

---

## 1. 개요 (Overview)

### 1.1 배경 및 문제 정의 (Problem Statement)
* **Weakest Link (가장 약한 고리) 현상:** 태양광 패널은 직렬(Series)로 연결되어 있어, 단 1장의 패널에 파손이나 오염이 발생해도 해당 스트링(String) 전체의 발전 효율이 급감함.
* **유지보수의 비효율성:**
    * 광범위한 발전소 부지를 사람이 육안으로 점검하는 것은 비용과 시간이 많이 소요됨.
    * 기존 열화상 드론 점검은 장비 도입 비용(CAPEX)이 높아 소규모 발전소에서 접근하기 어려움.
    * **CCTV의 유휴화:** 대부분의 발전소에 보안용 CCTV가 설치되어 있으나, 단순 방범용으로만 사용됨.

### 1.2 제품 목표 (Product Goal)
* **Zero-CAPEX:** 추가적인 하드웨어 센서 설치 없이, **기존 CCTV**를 활용하여 초기 도입 비용 0원으로 시스템 구축.
* **Dual-Track Solution:**
    * **Track A (Safety):** 화재나 시스템 셧다운을 유발하는 치명적 결함(파손)은 **즉시 경보**.
    * **Track B (Efficiency):** 단순 오염은 누적 데이터를 분석하여 **최적의 청소 시점(ROI)**을 제안.

### 1.3 MVP 범위 (Scope)
> [!IMPORTANT]
> 본 문서는 **Phase 1 MVP**에 집중합니다. 보안 강화, 장애 대응, 확장성은 Phase 2 이후 고도화 단계에서 다룹니다.

| MVP 포함 | MVP 제외 (Phase 2+) |
| :--- | :--- |
| 단일 CCTV 지원 | 다중 CCTV 지원 |
| 기본 결함 3종 분류 | 자체 회원가입, 비밀번호 관리 |
| 소셜 로그인 (Google/Kakao) | 상세 보안 정책, Rate Limiting |
| 기본 푸시 알림 | Kubernetes, Auto-scaling |
| **기상청 API 연동 (날씨 정보)** | 기상 예보 기반 자동 스케줄링 |
| Docker 기반 배포 | - |

---

## 2. 타겟 유저 및 페르소나 (User Persona)

| 구분 | 대상 | 니즈 (Needs) | Pain Point |
| :--- | :--- | :--- | :--- |
| **Main User** | **중소규모 발전소 관리자 (O&M)** | 적은 인원으로 효율적인 모니터링 원함 | 매일 현장을 돌며 패널을 확인할 시간이 부족함. |
| **Sub User** | **태양광 투자자 (소유주)** | 발전 수익(REC/SMP) 극대화 | 내 발전소가 지금 잘 돌아가는지, 청소비 대비 수익이 나오는지 모름. |

---

## 3. 핵심 기능 요구사항 (Functional Requirements)

### 3.1 AI 객체 탐지 및 분류 (Detection Logic)

#### [주제 1] 기본 분류 클래스 (Classification)
시스템은 CCTV 영상에서 패널 상태를 실시간으로 분석하여 아래 3가지 클래스로 분류해야 한다.

| 클래스 (Class) | 상태 정의 | 포함 항목 | 대응 로직 |
| :--- | :--- | :--- | :--- |
| **1. Defect** | **기계적 결함** | `Broken`(파손), `Crack`, `Hotspot`(그을림), `Burn` | **[Track A] 즉시 알림** (안전 사고 예방) |
| **2. Soiling** | **오염 및 가림** | `Dust`(먼지), `Bird_Drop`(새똥), `Leaves` | **[Track B] 리포트 누적** (청소 권고) |
| **3. Normal** | **정상 상태** | `Clean`, **`Shadow` (그림자)**, `Reflection` | **무시 (Ignore)** |

* **중요:** `Shadow`(그림자)는 시간 흐름에 따라 사라지므로 절대 결함으로 인식해서는 안 된다.

#### [주제 2] 모델 고도화 전략: 2단계 파이프라인 (Two-Stage Pipeline)
단순 탐지를 넘어 정밀 분류 성능을 극대화하기 위해 앙상블 대신 **2단계 검증 구조**를 채택함.

* **Stage 1 (Segmentation & Crop - SAM 3):**
    * **SAM 3 (Segment Anything 3)**를 활용하여 CCTV 영상 내의 태양광 패널 영역을 정밀하게 분할(Segmentation)하고 크롭(Crop).
    * 단순 사각형(BBox)이 아닌 패널의 정확한 형상을 추출하여 배경 노이즈를 제거.
* **Stage 2 (Expert Classifier):**
    * SAM 3로 Crop된 패널 이미지를 **정밀 분류 신경망(ResNet, EfficientNet, YOLO-Cls 등)**에 입력하여 최종 결함 종류(Defect vs Soiling vs Normal)를 확정.
* **채택 이유:**
    * 일반적인 객체 탐지(Detection) 모델은 배경(풀, 자갈 등)을 포함하여 학습하므로 오탐지가 발생할 수 있음.
    * 2단계 파이프라인은 SAM 3로 관심 영역을 완벽히 분리한 후 분류하므로, **분류 정확도(Precision)**를 획기적으로 높이면서 CCTV 환경에 최적화된 성능을 제공함.

### 3.2 실시간 모니터링 (Live Monitoring)
* **RTSP 스트리밍:** 앱 내 플레이어에서 CCTV 영상을 3초 이내 지연(Latency)으로 확인 가능해야 한다.
* **Visual Overlay:** AI가 탐지한 결함 위치에 바운딩 박스(Bounding Box)와 신뢰도(Confidence Score)를 시각적으로 표시한다.
    * 🔴 Red Box: Defect
    * 🟡 Yellow Box: Soiling

### 3.3 지능형 알림 및 리포트 (Alerts & Reports)
* **Push Notification:** `Defect` 등급 감지 시 관리자 앱으로 즉시 푸시 알림 발송 (이미지 스냅샷 포함).
* **경제성 분석 리포트:**
    * `Soiling` 면적과 발전 손실률을 추정하여 계산.
    * *"현재 오염으로 인해 월 5만 원 손실 중. 청소비(3만 원)보다 손실이 크므로 청소를 권장합니다."* 형태의 메시지 제공.

### 3.4 날씨 정보 연동 (Weather Integration)

기상청 단기예보 API를 연동하여 발전소 위치 기반 실시간 날씨 정보를 제공한다.

#### 기능 요구사항
| 기능 | 설명 | 활용 |
| :--- | :--- | :--- |
| **현재 날씨 표시** | 온도, 습도, 날씨 상태(맑음/흐림/비 등) | 대시보드 상단에 표시 |
| **일기 예보** | 12시간/3일 예보 정보 제공 | 청소 계획 수립 지원 |
| **우천 시 알림 중지** | 비/눈 감지 시 오염(Soiling) 알림 자동 중지 | 불필요한 알림 방지 |
| **발전량 예측 보조** | 일사량 정보 활용 | 예상 발전량 추정 |

#### API 연동 정보
* **데이터 출처:** 기상청 단기예보 조회서비스 (공공데이터포털)
* **갱신 주기:** 1시간마다 (API 호출 제한 고려)
* **필요 데이터:** 기온(T1H), 습도(REH), 강수형태(PTY), 하늘상태(SKY)

---

## 4. 인증 방식 (Authentication)

> [!NOTE]
> MVP에서는 소셜 로그인만 지원하여 개발 복잡도를 최소화합니다.

| 항목 | 방식 |
| :--- | :--- |
| **로그인** | OAuth 2.0 소셜 로그인 (Google, Kakao) |
| **인증 처리** | Firebase Authentication 활용 |
| **API 인증** | Firebase ID Token 검증 |

---

## 5. 데이터 및 기술 전략 (Data & Tech Strategy)

### 5.1 데이터셋 구축 전략
* **수량:** 총 45,000장 이상의 RGB 이미지 확보 (Roboflow Universe, Kaggle, GitHub 활용).
* **전처리 (Preprocessing):**
    * **SAM 3 (Segment Anything 3):** 데이터셋의 패널 영역 자동 추출 및 Single/Multi 패널 분류 자동화에 활용.
    * **Augmentation:** CCTV 환경 대응을 위한 밝기 조절, 노이즈 추가, 투시 변환(Perspective Transform) 적용.
* **저장소:** Google Cloud Storage (Region: `asia-northeast3`) 사용으로 전송 비용 최소화.

### 5.2 시스템 아키텍처 (MVP)

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Solar-Eye Architecture                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐     ┌──────────────────────────────────────────────┐  │
│  │  CCTV    │────▶│              Backend Server                   │  │
│  │  (RTSP)  │     │  ┌─────────┐  ┌─────────┐  ┌─────────────┐   │  │
│  └──────────┘     │  │ FastAPI │──│  Redis  │──│ PostgreSQL  │   │  │
│                   │  │  (API)  │  │ (Cache) │  │ (Main DB)   │   │  │
│                   │  └────┬────┘  └─────────┘  └─────────────┘   │  │
│                   │       │                                       │  │
│                   │  ┌────▼────────────────────────────────────┐ │  │
│                   │  │           AI Engine (GPU)                │ │  │
│                   │  │  ┌───────────┐    ┌──────────────────┐  │ │  │
│                   │  │  │   SAM 3   │───▶│ Classification   │  │ │  │
│                   │  │  │(Segment)  │    │ (ResNet/EffNet)  │  │ │  │
│                   │  │  └───────────┘    └──────────────────┘  │ │  │
│                   │  └─────────────────────────────────────────┘ │  │
│                   └──────────────────────────────────────────────┘  │
│                              │                                       │
│                              ▼                                       │
│                   ┌──────────────────┐                              │
│                   │   Flutter App    │                              │
│                   │  (Android/iOS)   │                              │
│                   └──────────────────┘                              │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.3 인프라 및 배포 전략 (Infra & Deployment Strategy)

#### 인프라 전략 (Infrastructure)
| 항목 | 전략 | 비고 |
| :--- | :--- | :--- |
| **Zero-CAPEX** | 초기 하드웨어 도입 비용 없이 **GCP(Google Cloud Platform)** 활용 | 클라우드 기반 운영으로 초기 투자 비용 제거 |
| **Region** | **서울 리전(asia-northeast3)** 전용 사용 | 데이터 전송 지연(Latency) 및 비용 최소화 |
| **Compute** | GCP Compute Engine (T4 GPU 인스턴스) | AI 추론 성능 확보 |
| **Storage** | Google Cloud Storage (asia-northeast3) | 모델 가중치, 스냅샷 이미지 저장 |

#### 배포 전략 (Deployment)
| 항목 | 전략 | 비고 |
| :--- | :--- | :--- |
| **Docker Container** | 개발(Local)과 운영(Cloud) 환경 불일치 문제 해결을 위해 **Docker** 기반 컨테이너 배포 원칙 준수 | 일관된 실행 환경 보장 |
| **Orchestration** | 백엔드(FastAPI), 데이터베이스(PostgreSQL), 캐시(Redis) 통합 관리를 위해 **Docker Compose** 사용 | 단일 명령어로 전체 스택 실행 |
| **Stability** | 서버 장애 시 즉각적인 재배포(Re-deploy) 및 복구 가능 환경 구축 | Docker 이미지 기반 빠른 롤백 |
| **CI/CD** | GitHub Actions를 통한 자동 빌드 및 배포 파이프라인 | (Phase 2 적용 예정) |

### 5.4 기술 스택 (MVP)

| 레이어 | 기술 | 용도 |
| :--- | :--- | :--- |
| **Backend** | Python 3.10 + FastAPI | 비동기 API 서버 |
| **AI Engine** | SAM 3 + PyTorch Classifier | 패널 분할 및 결함 분류 |
| **Database** | PostgreSQL 15 | 사용자, 패널, 로그 데이터 |
| **Frontend** | Flutter 3.x | Android/iOS 앱 |
| **Container** | Docker + Docker Compose | 컨테이너화 |
| **Cloud** | GCP Compute Engine (T4 GPU) | 프로덕션 배포 |

---

## 6. UI/UX 요구사항 (UI Guidelines)

### 6.1 메인 대시보드 (Dashboard)
* **신호등 UI:** 발전소 전체 상태를 직관적인 색상으로 표현.
    * 🟢 정상 (All Good)
    * 🟡 주의 (오염 누적, 청소 권고)
    * 🔴 위험 (파손 감지, 즉시 점검)
* **오늘의 발전 효율:** 예상 발전량 vs 실제 효율(추정치) 그래프.

### 6.2 상세 모니터링 화면
* CCTV 화면을 전체 화면으로 전환 가능.
* 결함 발생 타임라인(Timeline) 제공 (예: "14:00 새똥 감지됨").

---

## 7. 성공 지표 (Success Metrics & KPIs)

| 지표 | 목표치 | 측정 방법 |
| :--- | :--- | :--- |
| **탐지 정확도** | mAP@50 > 85% | Test Set 검증 결과 |
| **오탐지율 (Shadow)** | < 5% | 그림자를 결함으로 인식하는 비율 |
| **알림 Latency** | < 3초 | 결함 발생 → 앱 알림 도착 시간 |
| **영상 처리 FPS** | 30 FPS | Frame Skipping 적용 시 |

---

## 8. 향후 로드맵 (Future Plan)

| Phase | 목표 | 주요 기능 |
| :--- | :--- | :--- |
| **Phase 1 (MVP)** | 핵심 기능 구현 | 단일 CCTV, 기본 결함 3종 분류, **기상청 API 연동**, 클라우드 서버 구축 |
| **Phase 2** | 기능 확장 | 다중 CCTV 지원, 기상 예보 기반 자동 청소 스케줄링 |
| **Phase 3** | 온디바이스 AI | 엣지 디바이스(Jetson Nano) 포팅으로 통신 비용 제거 |
| **Phase 4** | 엔터프라이즈 | 멀티 테넌시, 대규모 발전소 대응, SaaS 모델 전환 |

---

## 9. 부록 (Appendix)

### 9.1 용어 정의 (Glossary)

| 용어 | 설명 |
| :--- | :--- |
| **O&M** | Operation & Maintenance (운영 및 유지보수) |
| **REC** | Renewable Energy Certificate (신재생에너지 공급인증서) |
| **SMP** | System Marginal Price (계통한계가격) |
| **RTSP** | Real-Time Streaming Protocol |
| **SAM 3** | Segment Anything Model 3 (Meta AI의 범용 세그멘테이션 모델) |
| **mAP** | Mean Average Precision (객체 탐지 정확도 지표) |

### 9.2 변경 이력 (Changelog)

| 버전 | 날짜 | 변경 내용 |
| :--- | :--- | :--- |
| v1.0 | 2026.01.10 | 초안 작성 |
| v1.1 | 2026.01.15 | Two-Stage Pipeline 전략 추가 |
| v1.2 | 2026.01.15 | 보안 요구사항, 장애 대응, 확장성, 기술 스택 상세화 추가 |
| v1.3 | 2026.01.15 | MVP 집중 버전 - 보안/장애대응/확장성 간소화, OAuth 소셜 로그인 적용 |

