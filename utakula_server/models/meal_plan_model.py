from sqlalchemy import JSON, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from models.models import Base  # Ensure Base is correctly imported
import uuid

class MealPlanModel(Base):
    __tablename__ = 'meal_plan'

    id: Mapped[str] = mapped_column(
        String(36), 
        primary_key=True,
        default=lambda: str(uuid.uuid4()),  
        unique=True,
        name='meal_plan_id'
    )
    
    # Use UUID for the user_id field to match UserModel's ID type
    user_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False
    )
    
    members: Mapped[list] = mapped_column(JSON, nullable=False)
    
    meal_plan: Mapped[dict] = mapped_column(JSON, nullable=False)

    # Define the reverse relationship with UserModel
    user = relationship("UserModel", back_populates="meal_plan")
