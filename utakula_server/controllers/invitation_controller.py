from fastapi import Body, HTTPException, Header, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
from models.user_model import UserModel

from schemas.invite_schema import InvitationBody, InviteBody, SendOutInvitesResponse, VerifyEmailsResponse
from models.meal_plan_model import MealPlanModel
from schemas.meal_plan_schema import MealPlanRead
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
            payload = utils.validate_JWT(token)
            
            list_of_emails = invite.list_of_emails
            
            existing_emails =  []
            invalid_emails = []
            
            for email in list_of_emails:
                user = db.query(UserModel).filter(UserModel.email == email).first()
                
                if user and user.id != payload['user_id']:
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
          
    
    
    def send_out_invites(self, invitationBody: InvitationBody, db: Session, authorization: str = Header(...)):
        """
        Send out invites and update the meal plan members.
        """
        try:
            # Validate authorization header
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )

            # Validate JWT
            token = authorization[7:]
            utils.validate_JWT(token)

            # Fetch the meal plan
            existing_meal_plan = db.query(MealPlanModel).filter(MealPlanModel.id == invitationBody.meal_plan_id).first()
            if not existing_meal_plan:
                return JSONResponse(
                    status_code=status.HTTP_404_NOT_FOUND,
                    content=SendOutInvitesResponse(
                        status="error",
                        message="Error fetching Meal plan!",
                        payload="Meal Plan not Found."
                    ).dict()
                )

            # Ensure members field is initialized
            list_of_members = existing_meal_plan.members or []

            # Validate invitation body
            if not invitationBody.list_of_emails:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="No emails provided in the invitation body."
                )

            # Query users based on the provided emails
            users = db.query(UserModel).filter(UserModel.email.in_(invitationBody.list_of_emails)).all()

            # Add user IDs to members if not already present
            for user in users:
                if user.id not in list_of_members:
                    list_of_members.append(user.id)

            # Update the members field
            existing_meal_plan.members = list_of_members

            # Commit changes
            print(f"Before commit: {existing_meal_plan.members}")
            db.commit()
            db.refresh(existing_meal_plan)
            print(f"After refresh: {existing_meal_plan.members}")

            # Return success response
            return {
                "status": "success",
                "message": "Invites sent successfully",
                "payload": MealPlanRead(
                    id=existing_meal_plan.id,
                    user_id=existing_meal_plan.user_id,
                    members=existing_meal_plan.members,
                    meal_plan=existing_meal_plan.meal_plan
                )
            }

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=SendOutInvitesResponse(
                    status="error",
                    message="Error when sending invites!",
                    payload=str(e)
                ).dict()
            )
