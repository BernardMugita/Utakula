from fastapi import HTTPException, Header, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from models.user_model import UserModel

from schemas.invite_schema import InviteBody, VerifyEmailsResponse
from utils.helper_utils import HelperUtils

utils = HelperUtils()

class InvitationController:
    def __init__(self) -> None:
        pass
    
    def verify_email_address(self, invite: InviteBody, db: Session, authorization: str = Header(...)) :
        """_summary_

        Args:
            db (Session): _description_
            authorization (str, optional): _description_. Defaults to Header(...).
        """
        
        try:
            if not authorization.startswith("Bearer "):
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail="Authorization header must start with 'Bearer '"
                    )

            token = authorization[7:]
            utils.validate_JWT(token)
            
            list_of_emails = invite.list_of_emails
            
            print(list_of_emails)
            
            existing_emails =  []
            invalid_emails = []
            
            for email in list_of_emails:
                address = db.query(UserModel).filter(UserModel.email == email).first()
                
                if address:
                    existing_emails.append(email)
                else:
                    invalid_emails.append(email)
                    
            return {
                    "status": "success",
                    "message": "Verified email addresses",
                    "payload": {
                        "existing_emails": existing_emails,
                        "invalid_emails": invalid_emails
                    }
                }             
            
        except Exception as e:
          return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=VerifyEmailsResponse(
                    status="error",
                    message="Error when validating emails!",
                    payload=str(e)
                ).dict()
            )