"""
Solar Eye Backend - Database Session Management

비동기 SQLAlchemy 세션 관리
"""

from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.pool import NullPool

from app.config import settings

# -----------------------------------------------------------------------------
# Async Engine 생성
# -----------------------------------------------------------------------------
# 프로덕션에서는 connection pooling 사용
# 테스트에서는 NullPool 사용 (연결 풀링 비활성화)

engine = create_async_engine(
    settings.get_database_url(),
    echo=settings.debug,  # SQL 쿼리 로깅 (개발 환경에서만)
    future=True,
    pool_pre_ping=True,  # 연결 상태 확인
)

# -----------------------------------------------------------------------------
# Async Session Factory
# -----------------------------------------------------------------------------
async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


# -----------------------------------------------------------------------------
# 의존성 주입용 세션 제너레이터
# -----------------------------------------------------------------------------
async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI 의존성 주입용 비동기 세션 제너레이터
    
    사용 예:
        @app.get("/items")
        async def get_items(session: AsyncSession = Depends(get_async_session)):
            ...
    """
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


# -----------------------------------------------------------------------------
# 테스트용 세션 팩토리 생성 함수
# -----------------------------------------------------------------------------
def create_test_engine(database_url: str):
    """테스트용 엔진 생성 (NullPool 사용)"""
    return create_async_engine(
        database_url,
        echo=True,
        future=True,
        poolclass=NullPool,
    )


def create_test_session_factory(test_engine):
    """테스트용 세션 팩토리 생성"""
    return async_sessionmaker(
        test_engine,
        class_=AsyncSession,
        expire_on_commit=False,
        autocommit=False,
        autoflush=False,
    )


# Alias for convenience (FastAPI 의존성 주입용)
get_db = get_async_session

