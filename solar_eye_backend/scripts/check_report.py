"""DB 리포트 확인 스크립트"""
import asyncio
from sqlalchemy import select
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
import sys
sys.path.insert(0, '.')
# Windows 출력 인코딩 설정
if sys.platform.startswith('win'):
    sys.stdout.reconfigure(encoding='utf-8')

from app.config import settings
from app.models.daily_report import DailyReport

async def check():
    engine = create_async_engine(settings.database_url)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with async_session() as s:
        result = await s.execute(select(DailyReport).order_by(DailyReport.id.desc()).limit(1))
        report = result.scalar_one_or_none()
        if report:
            wf = report.weather_forecast
            print('--- Weather Forecast Data ---')
            print(f'Condition: {wf.get("condition")}')
            print(f'Precipitation: {wf.get("precipitation")}')
            print(f'Temperature: {wf.get("temperature")}')
            print(f'Is Mock: {wf.get("is_mock")}')
            print('-----------------------------')
            print(f'AI Title: {report.ai_solution_title}')
        else:
            print('No report found')
    await engine.dispose()

asyncio.run(check())
