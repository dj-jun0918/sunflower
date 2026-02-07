from typing import List
import uuid
import random
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status, Body

from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.common import SuccessResponse
from app.schemas.services import ServiceCompany, ServiceRequest, ServiceRequestResponse

router = APIRouter()

# Mock Data
CLEANING_COMPANIES = [
    ServiceCompany(
        id="clean-co-1",
        name="솔라 클린 에너지",
        contact="010-1234-5678",
        rating=4.8,
        description="전문 장비를 활용한 태양광 패널 세척 서비스",
        service_type="cleaning"
    ),
    ServiceCompany(
        id="clean-co-2",
        name="그린 에너지 케어",
        contact="010-9876-5432",
        rating=4.5,
        description="드론 세척 전문, 빠르고 안전한 서비스",
        service_type="cleaning"
    ),
    ServiceCompany(
        id="clean-co-3",
        name="태양광 세척맨",
        contact="010-5555-4444",
        rating=4.2,
        description="합리적인 가격, 친환경 세제 사용",
        service_type="cleaning"
    )
]

REPAIR_COMPANIES = [
    ServiceCompany(
        id="repair-co-1",
        name="솔라 닥터",
        contact="010-1111-2222",
        rating=4.9,
        description="태양광 패널 유지보수 및 긴급 수리 전문",
        service_type="repair"
    ),
    ServiceCompany(
        id="repair-co-2",
        name="파워 픽스",
        contact="010-3333-7777",
        rating=4.6,
        description="인버터 및 패널 교체 전문",
        service_type="repair"
    )
]

@router.get(
    "/cleaning/companies",
    response_model=SuccessResponse[List[ServiceCompany]],
    summary="청소 업체 목록 조회",
    description="제휴된 태양광 패널 청소 업체 목록을 조회합니다."
)
async def get_cleaning_companies(
    current_user: User = Depends(get_current_user)
):
    return SuccessResponse(
        message="청소 업체 목록 조회 성공",
        data=CLEANING_COMPANIES
    )

@router.get(
    "/repair/companies",
    response_model=SuccessResponse[List[ServiceCompany]],
    summary="수리 업체 목록 조회",
    description="제휴된 태양광 패널 수리 업체 목록을 조회합니다."
)
async def get_repair_companies(
    current_user: User = Depends(get_current_user)
):
    return SuccessResponse(
        message="수리 업체 목록 조회 성공",
        data=REPAIR_COMPANIES
    )

@router.post(
    "/cleaning/request",
    response_model=SuccessResponse[ServiceRequestResponse],
    summary="청소 서비스 신청 (Mock)",
    description="특정 업체에 청소 서비스를 신청합니다. (Mock 동작)"
)
async def request_cleaning_service(
    request: ServiceRequest = Body(...),
    current_user: User = Depends(get_current_user)
):
    # Mock Processing
    company = next((c for c in CLEANING_COMPANIES if c.id == request.company_id), None)
    if not company:
        raise HTTPException(status_code=404, detail="업체를 찾을 수 없습니다.")

    # Generate Mock Response
    request_id = f"req-{uuid.uuid4().hex[:8]}"
    scheduled_date = datetime.now() + timedelta(days=random.randint(2, 7))
    
    response = ServiceRequestResponse(
        request_id=request_id,
        status="requested",
        company_name=company.name,
        scheduled_at=scheduled_date.strftime("%Y-%m-%d %H:00")
    )
    
    return SuccessResponse(
        message=f"{company.name}에 청소 신청이 접수되었습니다.",
        data=response
    )

@router.post(
    "/repair/request",
    response_model=SuccessResponse[ServiceRequestResponse],
    summary="수리 서비스 신청 (Mock)",
    description="특정 업체에 수리 서비스를 신청합니다. (Mock 동작)"
)
async def request_repair_service(
    request: ServiceRequest = Body(...),
    current_user: User = Depends(get_current_user)
):
    # Mock Processing
    company = next((c for c in REPAIR_COMPANIES if c.id == request.company_id), None)
    if not company:
        raise HTTPException(status_code=404, detail="업체를 찾을 수 없습니다.")

    # Generate Mock Response
    request_id = f"req-{uuid.uuid4().hex[:8]}"
    scheduled_date = datetime.now() + timedelta(days=random.randint(2, 7))
    
    response = ServiceRequestResponse(
        request_id=request_id,
        status="requested",
        company_name=company.name,
        scheduled_at=scheduled_date.strftime("%Y-%m-%d %H:00")
    )
    
    return SuccessResponse(
        message=f"{company.name}에 수리 신청이 접수되었습니다.",
        data=response
    )
