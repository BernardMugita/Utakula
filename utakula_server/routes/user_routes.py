from typing import List
from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
from connect import SessionLocal
from schemas.user_schema import DeleteAccountResponse, RetrieveUserResponse, UpdateAccountResponse, UserUpdate
from controllers.user_controller import UserController

router = APIRouter()
user_controller = UserController()

# Dependency to get the SQLAlchemy session
def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/users/get_all_users", response_model=RetrieveUserResponse) 
async def get_users(db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return user_controller.get_all_users(db, authorization)

@router.post("/users/get_user_by_id", response_model=RetrieveUserResponse) 
async def get_user(db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return user_controller.get_user_by_id(db, authorization)

@router.post("/users/edit_account", response_model=UpdateAccountResponse) 
async def edit_user_account(user_data: UserUpdate, db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return user_controller.edit_account_details(db, authorization, user_data)

@router.post("/users/delete_account", response_model=DeleteAccountResponse)  
async def delete_user_account(db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return user_controller.delete_account_details(db, authorization)
