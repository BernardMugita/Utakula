import uuid
from pydantic import BaseModel

from schemas.calorie_schema import CalorieRead


class FoodCreate(BaseModel):
    image_url: str
    name: str
    macro_nutrient: str
    meal_type: str
    
class FoodRead(BaseModel):
    id: uuid.UUID
    image_url: str
    name: str
    macro_nutrient: str
    meal_type: str
    calorie_breakdown: CalorieRead
    
class CreateFoodResponse(BaseModel):
    status: str
    message: str
    payload: FoodRead | str
    
class FoodUpdate(BaseModel):
    id: uuid.UUID
    image_url: str
    name: str
    macro_nutrient: str
    meal_type: str

class FoodGet(BaseModel):
    id: uuid.UUID    
    
class FoodDelete(BaseModel):
    id: uuid.UUID
    
class RetrieveFoodResponse(BaseModel):
    status: str
    message: str
    payload: FoodRead | list[FoodRead] | str
    
class UpdateFoodResponse(BaseModel):
    status: str
    message: str
    payload: FoodRead | str
    
class DeleteFoodResponse(BaseModel):
    status: str
    payload: str
    
    class Config:
        from_attributes = True