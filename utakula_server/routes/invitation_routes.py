# Dependency to get the SQLAlchemy session
from fastapi import APIRouter, Body, Depends, Header
from connect import SessionLocal
from controllers.invitation_controller import InvitationController
from schemas.invite_schema import InviteBody, VerifyEmailsResponse
from sqlalchemy.orm import Session

invite_controller = InvitationController()


def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        

router = APIRouter()
        
@router.post("/invite/verify_email_address", response_model=VerifyEmailsResponse)
async def create_food(
    invite: InviteBody = Body(...),
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return invite_controller.verify_email_address(invite, db, authorization)