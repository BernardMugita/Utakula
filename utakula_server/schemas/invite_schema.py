from pydantic import BaseModel

from schemas.meal_plan_schema import MealPlanRead

class InviteBody(BaseModel):
    list_of_emails: list[str]
    
class VerifyPayload(BaseModel):
    existing_emails: list[str]
    invalid_emails: list[str]
    
class InvitationBody(BaseModel):
    meal_plan_id: str
    list_of_emails: list[str]
    
class VerifyEmailsResponse(BaseModel):
    status: str
    message: str
    payload: VerifyPayload | str
    

class SendOutInvitesResponse(BaseModel):
    status: str
    message: str
    payload: MealPlanRead | str
    
    class Config:
            from_attributes = True