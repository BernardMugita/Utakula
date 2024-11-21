from fastapi import Body, HTTPException, status, Depends, Header
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from models.user_model import UserModel
from schemas.user_schema import DeleteAccountResponse, RetrieveUserResponse, UpdateAccountResponse, UserUpdate
from utils.helper_utils import HelperUtils

utils = HelperUtils()


class UserController:
    def __init__(self):
        pass

    def get_all_users(self, db: Session, authorization: str = Header(...)):
        """_summary_

        Args:
            db (Session): _description_
            authorization (str, optional): _description_. Defaults to Header(...).

        Raises:
            HTTPException: _description_
            HTTPException: _description_

        Returns:
            _type_: _description_ 
        """
       
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:] 
            payload = utils.validate_JWT(token)
            
            if payload['role'] != 'admin':
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="You are not authorized to access this route"
                )

            users = db.query(UserModel).all()  # Retrieve all users
            return {
                     "status": "success",
                     "message" : "Users retrieved successfully",
                     "payload": list(users)
                }
            
        except Exception as e:
          return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=RetrieveUserResponse(
                    status="error",
                    message="Error fetching users",
                    payload=f"{str(e)}"
                ).dict()
            )

    def get_user_by_id(self, db: Session, authorization: str = Header(...)):
        """_summary_

        Args:
            db (Session): _description_
            authorization (str, optional): _description_. Defaults to Header(...).

        Raises:
            HTTPException: _description_
            HTTPException: _description_
            HTTPException: _description_

        Returns:
            _type_: _description_
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:]  # Remove "Bearer " from the token
            payload = utils.validate_JWT(token)  # Validate the token
            
            print(UserModel.id)

            # If token is valid, proceed to get the user by ID
            user = db.query(UserModel).filter(UserModel.id == payload['user_id']).first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            return {
                    "status": "success",
                    "message": "User details retrieved successfully",
                    "payload": user
                }  
        except Exception as e:
           return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=RetrieveUserResponse(
                    status="error",
                    message="Failed to fetch user",
                    payload= f"{str(e)}",
                ).dict()
            )
          
    
    def edit_account_details(self, db: Session, authorization: str = Header(...), user_data: UserUpdate = Body(...)):
        """Edit the user's account details.

        Args:
            db (Session): Database session.
            authorization (str): Authorization header.
            user_data (UserUpdate): Data to update in the user's account.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:]  # Remove "Bearer " from the token
            payload = utils.validate_JWT(token)  # Validate the token

            # Get the user by ID from the validated JWT payload
            user = db.query(UserModel).filter(UserModel.id == payload['user_id']).first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            if user_data.email is not None:
                user.email = user_data.email

            # Commit the changes to the database
            db.commit()
            db.refresh(user)  # Refresh the instance to get updated data

            # Return a response indicating success
            return {
                "status": "success",
                "message": "Account details updated successfully",
                "payload": user
            }

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=UpdateAccountResponse(
                    status="error",
                    message="Error editing account",
                    payload=str(e)
                ).dict()
            )
            
            
    def delete_account_details(self, db: Session, authorization: str = Header(...)):
        """Delete the user's account.

        Args:
            db (Session): Database session.
            authorization (str): Authorization header.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:]  # Remove "Bearer " from the token
            payload = utils.validate_JWT(token)  # Validate the token

            user = db.query(UserModel).filter(UserModel.id == payload['user_id']).first()
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            db.delete(user)
            db.commit() 
            
            return {
                "status": "success",
                "payload": "Account deleted successfully",
            }

        except Exception as e:
            db.rollback() 
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=DeleteAccountResponse(
                    status="error",
                    payload=f"Error deleting account: {str(e)}",
                ).dict()
            )
