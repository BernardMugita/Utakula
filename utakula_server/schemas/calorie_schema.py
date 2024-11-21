import uuid
from pydantic import BaseModel, Field
from typing import Optional

# Pydantic Schemas
class NutrientBreakdown(BaseModel):
    amount: float | int = Field(..., description="The amount of the nutrient.")
    calories: float | int = Field(..., description="Calories derived from the nutrient.")
    unit:  str = Field(..., description="The unit for the nutrient amount, e.g., 'g'.")

class BreakdownSchema(BaseModel):
    carbohydrate: Optional[NutrientBreakdown] = None
    fat: Optional[NutrientBreakdown] = None
    fiber: Optional[NutrientBreakdown] = None
    protein: Optional[NutrientBreakdown] = None

class CalorieBreakdownSchema(BaseModel):
    total: int = Field(..., description="Total calories of the food item.")
    breakdown: BreakdownSchema

class CalorieRead(BaseModel):
    id: str
    food_id: str
    total: int
    breakdown: BreakdownSchema

class CalorieCreate(BaseModel):
    food_id: str
    total: int
    breakdown: BreakdownSchema

class CreateCalorieResponse(BaseModel):
    status: str
    message: str
    payload: CalorieRead | str
    
class FetchCalorieResponse(BaseModel):
    status: str
    message: str
    payload: CalorieRead | list[CalorieRead] | str
    
class UpdateCalorieResponse(BaseModel):
    status: str
    message: str
    payload: CalorieRead | str

class CalorieGet(BaseModel):
    food_id: str

class CalorieDelete(BaseModel):
    id: uuid.UUID

class CalorieUpdate(BaseModel):
    id: uuid.UUID
    total: Optional[int]
    breakdown: Optional[BreakdownSchema]