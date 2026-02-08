"""
Solar Eye Backend - Background Tasks

비동기 백그라운드 스케줄러 및 태스크 관리
"""

import asyncio
import logging
from datetime import datetime, time, timedelta
from typing import Callable, Dict, List, Optional

from app.config import settings

logger = logging.getLogger(__name__)


class BackgroundScheduler:
    """
    비동기 백그라운드 스케줄러
    
    주기적인 태스크 실행 및 일일 스케줄링을 담당합니다.
    
    사용 예시:
        scheduler = BackgroundScheduler()
        scheduler.add_interval_task("monitor", monitor_fn, interval=60)
        scheduler.add_daily_task("report", report_fn, hour=0, minute=0)
        await scheduler.start()
    """
    
    def __init__(self):
        self._tasks: Dict[str, asyncio.Task] = {}
        self._running = False
        self._interval_jobs: List[Dict] = []
        self._daily_jobs: List[Dict] = []
        
        logger.info("BackgroundScheduler 초기화")
    
    def add_interval_task(
        self,
        name: str,
        func: Callable,
        interval: float,
        run_immediately: bool = True,
    ):
        """
        주기적 태스크 추가
        
        Args:
            name: 태스크 이름
            func: 실행할 함수 (async 함수)
            interval: 실행 간격 (초)
            run_immediately: 즉시 실행 여부
        """
        self._interval_jobs.append({
            "name": name,
            "func": func,
            "interval": interval,
            "run_immediately": run_immediately,
        })
        logger.info(f"간격 태스크 등록: {name} (매 {interval}초)")
    
    def add_daily_task(
        self,
        name: str,
        func: Callable,
        hour: int = 0,
        minute: int = 0,
    ):
        """
        일일 태스크 추가 (매일 특정 시각에 실행)
        
        Args:
            name: 태스크 이름
            func: 실행할 함수 (async 함수)
            hour: 실행 시각 (시)
            minute: 실행 시각 (분)
        """
        self._daily_jobs.append({
            "name": name,
            "func": func,
            "hour": hour,
            "minute": minute,
        })
        logger.info(f"일일 태스크 등록: {name} (매일 {hour:02d}:{minute:02d})")
    
    async def _run_interval_task(self, job: Dict):
        """간격 태스크 실행 루프"""
        name = job["name"]
        func = job["func"]
        interval = job["interval"]
        
        if not job["run_immediately"]:
            await asyncio.sleep(interval)
        
        while self._running:
            try:
                logger.debug(f"태스크 실행: {name}")
                if asyncio.iscoroutinefunction(func):
                    await func()
                else:
                    func()
            except Exception as e:
                logger.error(f"태스크 {name} 실행 중 오류: {e}", exc_info=True)
            
            await asyncio.sleep(interval)
    
    async def _run_daily_task(self, job: Dict):
        """일일 태스크 실행 루프"""
        name = job["name"]
        func = job["func"]
        target_hour = job["hour"]
        target_minute = job["minute"]
        
        while self._running:
            now = datetime.now()
            target_time = now.replace(
                hour=target_hour,
                minute=target_minute,
                second=0,
                microsecond=0,
            )
            
            # 이미 지난 시각이면 다음 날로
            if target_time <= now:
                target_time += timedelta(days=1)
            
            # 대기 시간 계산
            wait_seconds = (target_time - now).total_seconds()
            logger.info(
                f"일일 태스크 {name}: 다음 실행까지 {wait_seconds:.0f}초 "
                f"({target_time.strftime('%Y-%m-%d %H:%M')})"
            )
            
            # 대기 (1분 단위로 체크하여 중지 요청 확인)
            while wait_seconds > 0 and self._running:
                sleep_time = min(wait_seconds, 60)
                await asyncio.sleep(sleep_time)
                wait_seconds -= sleep_time
            
            if not self._running:
                break
            
            # 태스크 실행
            try:
                logger.info(f"일일 태스크 실행: {name}")
                if asyncio.iscoroutinefunction(func):
                    await func()
                else:
                    func()
                logger.info(f"일일 태스크 완료: {name}")
            except Exception as e:
                logger.error(f"일일 태스크 {name} 실행 중 오류: {e}", exc_info=True)
    
    async def start(self):
        """스케줄러 시작"""
        if self._running:
            logger.warning("스케줄러가 이미 실행 중입니다")
            return
        
        self._running = True
        logger.info("BackgroundScheduler 시작")
        
        # 간격 태스크 시작
        for job in self._interval_jobs:
            task = asyncio.create_task(self._run_interval_task(job))
            self._tasks[f"interval_{job['name']}"] = task
        
        # 일일 태스크 시작
        for job in self._daily_jobs:
            task = asyncio.create_task(self._run_daily_task(job))
            self._tasks[f"daily_{job['name']}"] = task
        
        logger.info(
            f"스케줄러 시작됨: 간격 태스크 {len(self._interval_jobs)}개, "
            f"일일 태스크 {len(self._daily_jobs)}개"
        )
    
    async def stop(self):
        """스케줄러 중지"""
        if not self._running:
            return
        
        logger.info("BackgroundScheduler 중지 중...")
        self._running = False
        
        # 모든 태스크 취소
        for name, task in self._tasks.items():
            if not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
        
        self._tasks.clear()
        logger.info("BackgroundScheduler 중지 완료")
    
    @property
    def is_running(self) -> bool:
        """스케줄러 실행 중 여부"""
        return self._running


# =============================================================================
# 백그라운드 태스크 함수들
# =============================================================================

async def monitor_active_streams():
    """
    활성 스트림 모니터링 태스크
    
    활성화된 패널의 스트림 상태를 확인하고
    필요시 재시작합니다.
    """
    try:
        from app.ai.stream_processor import get_stream_manager, StreamStatus
        
        manager = get_stream_manager()
        statuses = manager.get_all_statuses()
        
        active_count = manager.get_active_count()
        total_count = len(statuses)
        
        logger.info(f"스트림 모니터링: 활성 {active_count}/{total_count}")
        
        # 에러 상태 스트림 로깅
        for panel_id, state in statuses.items():
            if state.status == StreamStatus.ERROR:
                logger.warning(
                    f"패널 {panel_id} 스트림 오류: {state.last_error}"
                )
                
    except Exception as e:
        logger.error(f"스트림 모니터링 중 오류: {e}")


async def generate_daily_reports():
    """
    일간 리포트 자동 생성 태스크
    
    모든 활성 패널에 대해 어제 날짜의 일간 리포트를 생성합니다.
    """
    from datetime import date, timedelta
    
    try:
        from sqlalchemy import select
        from app.db.session import async_session_maker
        from app.models.panel import Panel
        from app.services.report_service import ReportService
        
        yesterday = date.today() - timedelta(days=1)
        logger.info(f"일간 리포트 자동 생성 시작: {yesterday}")
        
        async with async_session_maker() as db:
            # 활성 패널 조회
            result = await db.execute(
                select(Panel).where(Panel.status == "active")
            )
            panels = result.scalars().all()
            
            if not panels:
                logger.info("활성 패널이 없습니다")
                return
            
            report_service = ReportService(db)
            generated_count = 0
            
            for panel in panels:
                try:
                    report = await report_service.get_or_create_daily_report(
                        user_id=panel.user_id,
                        panel_id=panel.id,
                        report_date=yesterday,
                    )
                    if report:
                        generated_count += 1
                except Exception as e:
                    logger.error(f"패널 {panel.id} 리포트 생성 실패: {e}")
            
            logger.info(
                f"일간 리포트 생성 완료: {generated_count}/{len(panels)}개"
            )
            
    except Exception as e:
        logger.error(f"일간 리포트 생성 중 오류: {e}", exc_info=True)


# =============================================================================
# 스케줄러 싱글톤 및 초기화
# =============================================================================

_scheduler: Optional[BackgroundScheduler] = None


def get_scheduler() -> BackgroundScheduler:
    """BackgroundScheduler 싱글톤 인스턴스 반환"""
    global _scheduler
    
    if _scheduler is None:
        _scheduler = BackgroundScheduler()
        
        # 기본 태스크 등록
        # 스트림 모니터링: 60초마다
        _scheduler.add_interval_task(
            "stream_monitor",
            monitor_active_streams,
            interval=60.0,
            run_immediately=False,
        )
        
        # 일간 리포트: 매일 자정 (00:05)
        _scheduler.add_daily_task(
            "daily_report",
            generate_daily_reports,
            hour=0,
            minute=5,
        )
    
    return _scheduler


async def start_scheduler():
    """스케줄러 시작 (main.py에서 호출)"""
    scheduler = get_scheduler()
    await scheduler.start()


async def stop_scheduler():
    """스케줄러 중지 (main.py에서 호출)"""
    global _scheduler
    
    if _scheduler:
        await _scheduler.stop()
        _scheduler = None
