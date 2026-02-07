"""
AI 브리핑 테스트를 위한 샘플 데이터 생성 스크립트
"""
import asyncio
import random
from datetime import datetime, date, timedelta

import sys
sys.path.insert(0, '.')

from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.config import settings
from app.models.user import User
from app.models.panel import Panel
from app.models.detection import Detection
from app.services.report_service import ReportService


async def create_test_data():
    """테스트 데이터 생성"""
    
    # DB 연결
    engine = create_async_engine(settings.database_url, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as session:
        # 1. 사용자 확인 또는 생성
        user_result = await session.execute(select(User).limit(1))
        user = user_result.scalar_one_or_none()
        
        if not user:
            print("테스트 사용자 생성 중...")
            user = User(
                firebase_uid="test_user_" + str(random.randint(1000, 9999)),
                email="test@solar-eye.com",
                display_name="테스트 관리자",
                is_active=True,
            )
            session.add(user)
            await session.commit()
            await session.refresh(user)
            print(f"✅ 사용자 생성: {user.display_name} (ID: {user.id})")
        else:
            print(f"기존 사용자 사용: {user.display_name} (ID: {user.id})")

        # 2. 패널 확인 또는 생성
        panel_result = await session.execute(
            select(Panel).where(Panel.user_id == user.id)
        )
        panels = list(panel_result.scalars().all())
        
        if not panels:
            print("테스트 패널 생성 중...")
            panel_names = ["A동 옥상 패널", "B동 주차장 패널", "창고동 패널"]
            for name in panel_names:
                panel = Panel(
                    user_id=user.id,
                    name=name,
                    location=f"춘천시 퇴계동 {random.randint(1, 100)}번지",
                    capacity_kw=random.uniform(5.0, 15.0),
                    panel_count=random.randint(10, 30),
                    latitude=37.87 + random.uniform(-0.01, 0.01),
                    longitude=127.73 + random.uniform(-0.01, 0.01),
                    status="active",
                )
                session.add(panel)
            await session.commit()
            
            panel_result = await session.execute(
                select(Panel).where(Panel.user_id == user.id)
            )
            panels = list(panel_result.scalars().all())
            print(f"✅ {len(panels)}개 패널 생성 완료")
        else:
            print(f"기존 패널 사용: {len(panels)}개")

        # 3. 오늘 날짜의 탐지 데이터 생성
        today = date.today()
        start_dt = datetime.combine(today, datetime.min.time())
        end_dt = datetime.combine(today + timedelta(days=1), datetime.min.time())
        
        # 기존 오늘 데이터 확인
        existing_result = await session.execute(
            select(Detection)
            .where(Detection.panel_id.in_([p.id for p in panels]))
            .where(Detection.detected_at >= start_dt)
            .where(Detection.detected_at < end_dt)
        )
        existing = list(existing_result.scalars().all())
        
        if existing:
            print(f"오늘 탐지 데이터 이미 존재: {len(existing)}건")
        else:
            print("오늘의 탐지 데이터 생성 중...")
            
            from app.models.detection import DefectType
            
            detections_to_add = []
            
            for panel in panels:
                # 각 패널당 10~20건의 탐지 데이터
                num_detections = random.randint(10, 20)
                
                for i in range(num_detections):
                    # 가중치: 정상 70%, 오염 25%, 결함 5%
                    dtype = random.choices(
                        [DefectType.NORMAL, DefectType.SOILING, DefectType.DEFECT], 
                        weights=[70, 25, 5]
                    )[0]
                    
                    confidence = random.uniform(0.7, 0.99)
                    area_pct = random.uniform(5, 35) if dtype == DefectType.SOILING else 0
                    
                    # 오늘 시간대 중 랜덤
                    hour = random.randint(6, 18)
                    minute = random.randint(0, 59)
                    detected_at = datetime.combine(today, datetime.min.time()).replace(
                        hour=hour, minute=minute
                    )
                    
                    detection = Detection(
                        panel_id=panel.id,
                        defect_type=dtype,
                        confidence=confidence,
                        area_percentage=area_pct,
                        detected_at=detected_at,
                        snapshot_url=f"/images/detection_{panel.id}_{i}.jpg",
                        bbox_x=random.randint(0, 800),
                        bbox_y=random.randint(0, 600),
                        bbox_width=random.randint(50, 200),
                        bbox_height=random.randint(50, 200),
                    )
                    detections_to_add.append(detection)
            
            session.add_all(detections_to_add)
            await session.commit()
            print(f"✅ {len(detections_to_add)}건 탐지 데이터 생성 완료")

        # 4. AI 브리핑 생성
        print("\n🤖 AI 브리핑 생성 중...")
        report_service = ReportService(session)
        
        try:
            report = await report_service.generate_ai_briefing(
                user_id=user.id,
                target_date=today,
            )
            
            if report:
                print(f"\n✅ AI 브리핑 생성 완료!")
                print(f"   📅 날짜: {report.report_date}")
                print(f"   🏷️ 타입: {report.ai_solution_type}")
                print(f"   📌 제목: {report.ai_solution_title}")
                print(f"   📝 내용: {report.ai_solution_content[:100]}...")
                print(f"   ✅ 액션 아이템: {report.ai_action_items}")
                print(f"   ⚠️ 특이사항: {report.anomalies}")
            else:
                print("⚠️ AI 브리핑 생성 실패 (데이터 부족)")
        except Exception as e:
            print(f"❌ AI 브리핑 생성 오류: {e}")
            import traceback
            traceback.print_exc()

    await engine.dispose()
    print("\n✅ 테스트 데이터 생성 완료!")


if __name__ == "__main__":
    asyncio.run(create_test_data())
