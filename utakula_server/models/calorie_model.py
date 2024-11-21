import uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import ForeignKey, JSON, String
from models.models import Base

class CalorieModel(Base):
    __tablename__ = 'calories'
    
    id: Mapped[str] = mapped_column(
        String(36), 
        primary_key=True,
        default=lambda: str(uuid.uuid4()), 
        unique=True,
        name='calorie_id'
    )
    food_id: Mapped[str] = mapped_column(ForeignKey("foods.food_id"), nullable=False, unique=True)
    total: Mapped[int] = mapped_column(nullable=False)
    breakdown: Mapped[dict] = mapped_column(JSON, nullable=False)

    # Relationship with FoodModel
    food = relationship("FoodModel", back_populates="calories")