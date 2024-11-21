from models.models import Base
from models.user_model import UserModel
from models.calorie_model import CalorieModel
from models.food_model import FoodModel
from models.meal_plan_model import MealPlanModel
from connect import engine

print("CREATING TABLES >>>>>")
Base.metadata.create_all(bind=engine)