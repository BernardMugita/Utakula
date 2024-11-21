from pydantic import BaseModel

class InviteBody(BaseModel):
    list_of_emails: list[str]
    
class VerifyPayload(BaseModel):
    existing_emails: list[str]
    invalid_emails: list[str]
    
class VerifyEmailsResponse(BaseModel):
    status: str
    message: str
    payload: VerifyPayload | str