from fastapi import APIRouter, Body, Depends, Header
from sqlalchemy.orm import Session
from connect import SessionLocal
from controllers.calorie_controller import CalorieController
from schemas.calorie_schema import (
    CalorieCreate, CalorieGet, CalorieUpdate, CreateCalorieResponse, CalorieRead, FetchCalorieResponse, UpdateCalorieResponse
)

router = APIRouter()
calorie_controller = CalorieController()

# Dependency to get the SQLAlchemy session
def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/calories/add_calorie", response_model=CreateCalorieResponse)
async def add_calorie(
    db: Session = Depends(get_db_connection),
    calorie_data: CalorieCreate = Body(...),
    authorization: str = Header(...)
):
    return calorie_controller.add_new_calorie_data(calorie_data, db, authorization)

@router.post("/calories/get_all_calories", response_model=FetchCalorieResponse)
async def get_all_calories(
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return calorie_controller.get_all_calories(db, authorization)

@router.post("/calories/get_calorie_by_food_id", response_model=FetchCalorieResponse)
async def get_calorie_by_food_id(
    db: Session = Depends(get_db_connection),
    calorie_data: CalorieGet = Body(...),
    authorization: str = Header(...)
):
    return calorie_controller.get_calorie_by_food_id(db, calorie_data, authorization)

@router.post("/calories/update_calorie_info", response_model=UpdateCalorieResponse)
async def update_calorie(
    db: Session = Depends(get_db_connection),
    calorie_data: CalorieUpdate = Body(...),
    authorization: str = Header(...)
):
    return calorie_controller.update_calorie_info(db, calorie_data, authorization)
