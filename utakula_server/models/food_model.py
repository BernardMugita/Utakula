import uuid
from enum import Enum
from sqlalchemy import String, Enum as SqlEnum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from models.models import Base

class MealTypeEnum(str, Enum):
    BREAKFAST = "breakfast or snack"
    SUPPER_OR_LUNCH = "lunch or supper"
    FRUIT = "fruit"
    BEVERAGE = "beverage"
    

class FoodModel(Base):
    __tablename__ = 'foods'
    
    id: Mapped[str] = mapped_column(
        String(36), 
        primary_key=True,
        default=lambda: str(uuid.uuid4()), 
        unique=True,
        name='food_id'
    )
    image_url: Mapped[str] = mapped_column(String(100), nullable=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    macro_nutrient: Mapped[str] = mapped_column(String(50), nullable=False)
    
    # Enum type for meal_type
    meal_type: Mapped[MealTypeEnum] = mapped_column(SqlEnum(MealTypeEnum), nullable=False)
    
    # Relationship with CalorieModel
    calories = relationship("CalorieModel", back_populates="food", uselist=False)  # 'food' matches CalorieModel’s relationship attribute
