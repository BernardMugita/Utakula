from typing import List
from fastapi import APIRouter, Body, Depends, Header
from sqlalchemy.orm import Session
from connect import SessionLocal

from controllers.meal_plan_controller import MealPlanController
from schemas.meal_plan_schema import CreateMealPlanResponse, FetchMemberPlansResponse, MealPlanCreate, MealPlanUpdate, RetrieveMealPlanResponse, UpdateMealPlanResponse

router = APIRouter()
meal_plan_controller = MealPlanController()

# Dependency to get the SQLAlchemy session
def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
        
@router.post("/meal_plans/add_new_plan", response_model=CreateMealPlanResponse)
async def create_food(
    meal_plan_data: MealPlanCreate = Body(...),
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return meal_plan_controller.create_meal_plan(meal_plan_data, db, authorization)


@router.post("/meal_plans/get_user_meal_plan", response_model=RetrieveMealPlanResponse) 
async def get_food(db: Session = Depends(get_db_connection), authorization: str = Header(...)):
    return meal_plan_controller.get_user_meal_plan(db, authorization)

@router.post("/meal_plans/update_meal_plan", response_model=UpdateMealPlanResponse)
async def update_meal_plan(
    db: Session = Depends(get_db_connection), 
    meal_plan_data: MealPlanUpdate = Body(...),
    authorization: str = Header(...)
):
    return meal_plan_controller.update_user_meal_plan(db, meal_plan_data, authorization)

@router.post("/meal_plans/fetch_plans", response_model=FetchMemberPlansResponse)
async def fetch_member_meal_plans(
    db: Session = Depends(get_db_connection),
    authorization: str = Header(...)
):
    return meal_plan_controller.get_member_meal_plans(db, authorization)