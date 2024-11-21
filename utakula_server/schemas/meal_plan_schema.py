import json
from typing import Dict, Union
import uuid
from pydantic import BaseModel

class SelectedFood(BaseModel):
    id: str
    name: str
    image_url: str
    calories: int | float
    
class Member(BaseModel):
    id: str

class MealCreate(BaseModel):
    breakfast: list[SelectedFood]
    lunch: list[SelectedFood]
    supper: list[SelectedFood]

class DayMealPlan(BaseModel):
    day: str
    meals: MealCreate
    total_calories: int | float
    
class MealPlanCreate(BaseModel):
    meal_plan: list[DayMealPlan]
    
class MealPlanRead(BaseModel):
    id: uuid.UUID
    user_id: str
    members: Dict[str, Member]
    meal_plan: list[DayMealPlan]
    
class MealPlanUpdate(BaseModel):
    meal_plan: list[DayMealPlan]

class CreateMealPlanResponse(BaseModel):
    status: str
    message: str
    payload: MealPlanRead | str
    
class MealPlanGet(BaseModel):
    id: uuid.UUID 
    
class RetrieveMealPlanResponse(BaseModel):
    status: str
    message: str
    payload: MealPlanRead | list[MealPlanRead] | str
    
class UpdateMealPlanResponse(BaseModel):
    status: str
    message: str
    payload: Union[MealPlanRead, str]
    
    class Config:
            from_attributes = True