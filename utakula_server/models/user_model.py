import uuid
from sqlalchemy import String
from sqlalchemy.orm import relationship, Mapped, mapped_column
from passlib.context import CryptContext
from models.models import Base

# Configure the password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
 
class UserModel(Base):
    __tablename__ = 'users'
    
    id: Mapped[str] = mapped_column(
        String(36), 
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
        unique=True,
        name='user_id'
    )
    username: Mapped[str] = mapped_column(String(50), nullable=False, unique=True)
    role: Mapped[str] = mapped_column(String(50), nullable=False, default="user")
    email: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)
    _password_hash: Mapped[str] = mapped_column(String(100), name="password", nullable=False)

    meal_plan = relationship("MealPlanModel", back_populates="user", uselist=False)

    def set_password(self, password: str):
        """Hashes and stores the user's password."""
        self._password_hash = pwd_context.hash(password)

    def verify_password(self, password: str) -> bool:
        """Verifies the provided password against the stored hash."""
        return pwd_context.verify(password, self._password_hash)
