"""
Solar Eye Backend - RTSP Stream Processor

PyAV 기반 RTSP 스트림 처리 및 AI 파이프라인 연동
"""

import asyncio
import logging
import time
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Callable, Dict, List, Optional

import cv2
import numpy as np

try:
    import av
    AV_AVAILABLE = True
except ImportError:
    AV_AVAILABLE = False

from app.config import settings

logger = logging.getLogger(__name__)


class StreamStatus(str, Enum):
    """스트림 상태"""
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    STREAMING = "streaming"
    ERROR = "error"
    STOPPED = "stopped"


@dataclass
class StreamConfig:
    """스트림 설정"""
    rtsp_url: str
    panel_id: int
    fps: float = 1.0  # 초당 프레임 수 (기본 1fps)
    reconnect_interval: float = 5.0  # 재연결 간격 (초)
    max_reconnect_attempts: int = 5  # 최대 재연결 시도 횟수
    connection_timeout: float = 10.0  # 연결 타임아웃 (초)


@dataclass
class FrameData:
    """프레임 데이터"""
    frame: np.ndarray
    timestamp: datetime
    frame_number: int
    panel_id: int


@dataclass
class StreamState:
    """스트림 상태 정보"""
    status: StreamStatus = StreamStatus.DISCONNECTED
    last_frame_time: Optional[datetime] = None
    frame_count: int = 0
    error_count: int = 0
    last_error: Optional[str] = None
    reconnect_attempts: int = 0


class RTSPStreamProcessor:
    """
    RTSP 스트림 처리기
    
    PyAV를 사용하여 RTSP 스트림에서 프레임을 추출하고
    AI 파이프라인과 연동합니다.
    
    사용 예시:
        processor = RTSPStreamProcessor(config)
        await processor.start(on_frame_callback)
    """
    
    def __init__(self, config: StreamConfig):
        """
        Args:
            config: 스트림 설정
        """
        if not AV_AVAILABLE:
            raise ImportError("PyAV가 설치되어 있지 않습니다. 'pip install av'를 실행하세요.")
        
        self.config = config
        self.state = StreamState()
        self._container: Optional[av.container.InputContainer] = None
        self._running = False
        self._task: Optional[asyncio.Task] = None
        
        logger.info(f"RTSPStreamProcessor 초기화 - 패널 ID: {config.panel_id}")
    
    @property
    def is_running(self) -> bool:
        """스트림 실행 중 여부"""
        return self._running
    
    @property
    def status(self) -> StreamStatus:
        """현재 스트림 상태"""
        return self.state.status
    
    def _connect(self) -> bool:
        """RTSP 스트림 연결"""
        try:
            self.state.status = StreamStatus.CONNECTING
            logger.info(f"RTSP 연결 시도: {self.config.rtsp_url[:50]}...")
            
            # PyAV 옵션 설정
            options = {
                "rtsp_transport": "tcp",  # TCP 사용 (안정성)
                "stimeout": str(int(self.config.connection_timeout * 1000000)),  # 마이크로초
                "max_delay": "500000",
            }
            
            self._container = av.open(
                self.config.rtsp_url,
                options=options,
                timeout=(self.config.connection_timeout, None),
            )
            
            self.state.status = StreamStatus.CONNECTED
            self.state.reconnect_attempts = 0
            self.state.error_count = 0
            logger.info(f"RTSP 연결 성공 - 패널 ID: {self.config.panel_id}")
            return True
            
        except av.error.TimeoutError:
            self.state.status = StreamStatus.ERROR
            self.state.last_error = "연결 타임아웃"
            logger.error(f"RTSP 연결 타임아웃: {self.config.rtsp_url}")
            return False
            
        except Exception as e:
            self.state.status = StreamStatus.ERROR
            self.state.last_error = str(e)
            logger.error(f"RTSP 연결 실패: {e}")
            return False
    
    def _disconnect(self):
        """RTSP 스트림 연결 해제"""
        if self._container:
            try:
                self._container.close()
            except Exception as e:
                logger.warning(f"스트림 종료 중 오류: {e}")
            finally:
                self._container = None
        
        self.state.status = StreamStatus.DISCONNECTED
        logger.info(f"RTSP 연결 해제 - 패널 ID: {self.config.panel_id}")
    
    async def _extract_frames(
        self,
        on_frame: Callable[[FrameData], None],
    ):
        """
        프레임 추출 루프
        
        Args:
            on_frame: 프레임 수신 시 호출할 콜백 함수
        """
        if not self._container:
            return
        
        self.state.status = StreamStatus.STREAMING
        frame_interval = 1.0 / self.config.fps
        last_frame_time = 0.0
        
        try:
            video_stream = self._container.streams.video[0]
            video_stream.thread_type = "AUTO"
            
            for frame in self._container.decode(video_stream):
                if not self._running:
                    break
                
                current_time = time.time()
                
                # FPS 제한 적용
                if current_time - last_frame_time < frame_interval:
                    continue
                
                last_frame_time = current_time
                
                # PIL Image → numpy array (BGR)
                img = frame.to_ndarray(format="bgr24")
                
                # 프레임 데이터 생성
                frame_data = FrameData(
                    frame=img,
                    timestamp=datetime.now(),
                    frame_number=self.state.frame_count,
                    panel_id=self.config.panel_id,
                )
                
                self.state.frame_count += 1
                self.state.last_frame_time = frame_data.timestamp
                
                # 콜백 호출 (비동기 처리를 위해 별도 태스크로)
                try:
                    on_frame(frame_data)
                except Exception as e:
                    logger.error(f"프레임 콜백 처리 중 오류: {e}")
                
                # 이벤트 루프에 제어권 양도
                await asyncio.sleep(0)
                
        except av.error.EOFError:
            logger.warning(f"스트림 종료 (EOF) - 패널 ID: {self.config.panel_id}")
        except Exception as e:
            self.state.error_count += 1
            self.state.last_error = str(e)
            logger.error(f"프레임 추출 중 오류: {e}")
    
    async def start(
        self,
        on_frame: Callable[[FrameData], None],
    ):
        """
        스트림 처리 시작
        
        Args:
            on_frame: 프레임 수신 시 호출할 콜백 함수
        """
        if self._running:
            logger.warning("스트림이 이미 실행 중입니다")
            return
        
        self._running = True
        logger.info(f"스트림 처리 시작 - 패널 ID: {self.config.panel_id}")
        
        while self._running:
            # 연결 시도
            if not self._connect():
                self.state.reconnect_attempts += 1
                
                if self.state.reconnect_attempts >= self.config.max_reconnect_attempts:
                    logger.error(
                        f"최대 재연결 시도 횟수 초과 - 패널 ID: {self.config.panel_id}"
                    )
                    self.state.status = StreamStatus.ERROR
                    break
                
                logger.info(
                    f"재연결 대기 ({self.state.reconnect_attempts}/"
                    f"{self.config.max_reconnect_attempts})..."
                )
                await asyncio.sleep(self.config.reconnect_interval)
                continue
            
            # 프레임 추출
            await self._extract_frames(on_frame)
            
            # 연결 해제 후 재연결 대기
            self._disconnect()
            
            if self._running:
                logger.info(f"스트림 재연결 대기 중...")
                await asyncio.sleep(self.config.reconnect_interval)
        
        self._disconnect()
        self.state.status = StreamStatus.STOPPED
        logger.info(f"스트림 처리 종료 - 패널 ID: {self.config.panel_id}")
    
    async def stop(self):
        """스트림 처리 중지"""
        logger.info(f"스트림 중지 요청 - 패널 ID: {self.config.panel_id}")
        self._running = False
        
        if self._task and not self._task.done():
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
        
        self._disconnect()
    
    def get_state(self) -> StreamState:
        """현재 스트림 상태 반환"""
        return self.state


class StreamManager:
    """
    다중 RTSP 스트림 관리자
    
    여러 패널의 RTSP 스트림을 동시에 관리합니다.
    
    사용 예시:
        manager = StreamManager()
        await manager.start_stream(panel_id, rtsp_url, on_frame)
        await manager.stop_stream(panel_id)
    """
    
    def __init__(self):
        self._processors: Dict[int, RTSPStreamProcessor] = {}
        self._tasks: Dict[int, asyncio.Task] = {}
        self._frame_callbacks: Dict[int, Callable[[FrameData], None]] = {}
        
        logger.info("StreamManager 초기화")
    
    async def start_stream(
        self,
        panel_id: int,
        rtsp_url: str,
        on_frame: Callable[[FrameData], None],
        fps: float = 1.0,
    ):
        """
        패널 스트림 시작
        
        Args:
            panel_id: 패널 ID
            rtsp_url: RTSP URL
            on_frame: 프레임 콜백
            fps: 초당 프레임 수
        """
        if panel_id in self._processors:
            logger.warning(f"패널 {panel_id} 스트림이 이미 실행 중입니다")
            return
        
        config = StreamConfig(
            rtsp_url=rtsp_url,
            panel_id=panel_id,
            fps=fps,
        )
        
        processor = RTSPStreamProcessor(config)
        self._processors[panel_id] = processor
        self._frame_callbacks[panel_id] = on_frame
        
        # 백그라운드 태스크로 스트림 시작
        task = asyncio.create_task(processor.start(on_frame))
        self._tasks[panel_id] = task
        
        logger.info(f"패널 {panel_id} 스트림 시작됨")
    
    async def stop_stream(self, panel_id: int):
        """
        패널 스트림 중지
        
        Args:
            panel_id: 패널 ID
        """
        if panel_id not in self._processors:
            logger.warning(f"패널 {panel_id} 스트림이 없습니다")
            return
        
        processor = self._processors[panel_id]
        await processor.stop()
        
        # 태스크 정리
        if panel_id in self._tasks:
            task = self._tasks[panel_id]
            if not task.done():
                task.cancel()
                try:
                    await task
                except asyncio.CancelledError:
                    pass
            del self._tasks[panel_id]
        
        del self._processors[panel_id]
        if panel_id in self._frame_callbacks:
            del self._frame_callbacks[panel_id]
        
        logger.info(f"패널 {panel_id} 스트림 중지됨")
    
    async def stop_all(self):
        """모든 스트림 중지"""
        logger.info("모든 스트림 중지 중...")
        
        panel_ids = list(self._processors.keys())
        for panel_id in panel_ids:
            await self.stop_stream(panel_id)
        
        logger.info("모든 스트림 중지 완료")
    
    def get_stream_status(self, panel_id: int) -> Optional[StreamState]:
        """
        패널 스트림 상태 조회
        
        Args:
            panel_id: 패널 ID
            
        Returns:
            StreamState 또는 None
        """
        if panel_id not in self._processors:
            return None
        return self._processors[panel_id].get_state()
    
    def get_all_statuses(self) -> Dict[int, StreamState]:
        """모든 스트림 상태 조회"""
        return {
            panel_id: processor.get_state()
            for panel_id, processor in self._processors.items()
        }
    
    def get_active_count(self) -> int:
        """활성 스트림 개수"""
        return sum(
            1 for processor in self._processors.values()
            if processor.status == StreamStatus.STREAMING
        )


# 싱글톤 인스턴스
_stream_manager: Optional[StreamManager] = None


def get_stream_manager() -> StreamManager:
    """StreamManager 싱글톤 인스턴스 반환"""
    global _stream_manager
    
    if _stream_manager is None:
        _stream_manager = StreamManager()
    
    return _stream_manager
