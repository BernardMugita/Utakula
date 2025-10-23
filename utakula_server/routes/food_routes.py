from typing import List
from fastapi import APIRouter, Body, Depends, Header
from sqlalchemy.orm import Session
from connect import SessionLocal

from controllers.food_controller import FoodController
from schemas.food_schema import (
    FoodCreate, FoodDelete, FoodGet, FoodRead, FoodUpdate, RetrieveFoodResponse, 
    UpdateFoodResponse, DeleteFoodResponse, CreateFoodResponse
)

router = APIRouter()
food_controller = FoodController()

# Dependency to get the SQLAlchemy session
def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
@router.post("/foods/add_new_food", response_model=CreateFoodResponse)
async def create_food(
    food_data: FoodCreate,
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return food_controller.add_new_food(food_data, db, authorization)

@router.post("/foods/get_all_foods", response_model=RetrieveFoodResponse) 
async def get_foods(db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return food_controller.get_all_foods(db, authorization)

@router.post("/foods/get_food_by_id", response_model=RetrieveFoodResponse) 
async def get_food(db: Session = Depends(get_db_connection), food_data: FoodGet = Body(...), authorization: str = Header(...)):
    return food_controller.get_food_by_id(db, food_data, authorization)

@router.post("/foods/edit_food", response_model=UpdateFoodResponse) 
async def edit_food(food_data: FoodUpdate, db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return food_controller.edit_food_details(db, authorization, food_data)

@router.post("/foods/delete_food", response_model=DeleteFoodResponse)  
async def delete_food(db: Session = Depends(get_db_connection), food_data: FoodDelete = Body(...), authorization: str = Header(...)):
    return food_controller.delete_food_details(db, food_data, authorization)
