# Dependency to get the SQLAlchemy session
from fastapi import APIRouter, Body, Depends, Header
from connect import SessionLocal
from controllers.invitation_controller import InvitationController
from schemas.invite_schema import InvitationBody, InviteBody, SendOutInvitesResponse, VerifyEmailsResponse
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
async def verify_emails(
    invite: InviteBody = Body(...),
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return invite_controller.verify_email_address(invite, db, authorization)


@router.post("/invite/send_out_invites", response_model=SendOutInvitesResponse)
async def send_out_invites(
    invite: InvitationBody = Body(...),
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return invite_controller.send_out_invites(invite, db, authorization)