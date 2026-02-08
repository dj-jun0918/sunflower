from typing import List, Optional
from pydantic import BaseModel

class ServiceCompany(BaseModel):
    id: str
    name: str
    contact: str
    rating: float
    description: Optional[str] = None
    service_type: str # "cleaning" or "repair"

class ServiceRequest(BaseModel):
    facility_id: int
    company_id: str
    request_details: Optional[str] = None

class ServiceRequestResponse(BaseModel):
    request_id: str
    status: str
    company_name: str
    scheduled_at: Optional[str] = None
