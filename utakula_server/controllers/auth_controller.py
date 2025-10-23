# user_controller.py
from sqlalchemy.orm import Session
from models.user_model import UserModel
from schemas.user_schema import RegisterResponse, UserAuthorize, UserCreate, UserRead, SignedUser, AuthResponse
from passlib.context import CryptContext
from fastapi import HTTPException, status
from fastapi.responses import JSONResponse
from datetime import datetime, timedelta
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

SECRET_KEY = os.getenv("ACCESS_SECRET")
ALGORITHM = "HS256"

# Configure the password hashing context
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")

class AuthController:
    def __init__(self):
        pass

    def hash_password(self, password: str) -> str:
        """Hash a plain password."""
        return pwd_context.hash(password)

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash."""
        return pwd_context.verify(plain_password, hashed_password)

    def generate_jwt_token(self, user: SignedUser) -> str:
        """Generate a JWT token for the user."""
        payload = {
            "user_id": user.id,
            "username": user.username,
            "role": user.role,
            "exp": datetime.utcnow() + timedelta(days=4)
        }
        return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

    def create_user_account(self, user_data: UserCreate, db: Session) -> UserRead:
        """_summary_

        Args:
            user_data (UserCreate): _description_
            db (Session): _description_

        Raises:
            HTTPException: _description_

        Returns:
            UserRead: _description_
        """

        try:
            # Check if the user already exists by email or username
            existing_user = db.query(UserModel).filter(
                (UserModel.email == user_data.email) |
                (UserModel.username == user_data.username)
            ).first()

            if existing_user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="User with this email or username already exists."
                )

            # Create a new user and hash the password
            new_user = UserModel(
                username=user_data.username,
                email=user_data.email,
            )
            new_user.set_password(user_data.password)

            # Add to the database and commit
            db.add(new_user)
            db.commit()
            db.refresh(new_user)

            # Create a UserRead instance to return
            user_response = UserRead(
                id=new_user.id,
                username=new_user.username,
                role=new_user.role,
                email=new_user.email
            )

            # Return a successful response with the user details and status code 201
            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content=RegisterResponse(
                    status="success",
                    message="Account created successfully.",
                    payload=str(user_response)
                ).dict()
            )

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=AuthResponse(
                    status="error",
                    message="Registration failed",
                    payload=f"{str(e)}"
                ).dict()
            )
            
    def authorize_user_account(self, user_data: UserAuthorize, db: Session) -> JSONResponse:
        """_summary_

        Args:
            user_data (UserAuthorize): _description_
            db (Session): _description_

        Returns:
            JSONResponse: _description_
        """
        
        try:
            # Check if the user exists
            existing_user = db.query(UserModel).filter(
                UserModel.username == user_data.username
            ).first()

            if not existing_user:
                # Return 400 error if user not found
                return JSONResponse(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    content=AuthResponse(
                        status="error",
                        message="404",
                        payload="User account does not exist."
                    ).dict()
                )
        
            # Verify the password
            if not existing_user.verify_password(user_data.password):
                # Return 401 error if password is incorrect
                return JSONResponse(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    content=AuthResponse(
                        status="error",
                        message="Failed. Try again!",
                        payload="Incorrect password."
                    ).dict()
                )
            
            # Generate JWT token for the user
            token = self.generate_jwt_token(
                SignedUser(
                    id=str(existing_user.id),
                    username=existing_user.username,
                    role=existing_user.role,
                )
            )
        
            # Return 200 success response with token payload
            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content=AuthResponse(
                    status="success",
                    message="Authorized",
                    payload=token
                ).dict()
            )
            
        except Exception as e:
            # Return 500 error on any unexpected failure
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=AuthResponse(
                    status="error",
                    message="Account authorization failed",
                    payload=f"{str(e)}"
                ).dict()
            )
