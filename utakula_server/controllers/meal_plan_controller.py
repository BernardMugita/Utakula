from fastapi import HTTPException, Header, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from models.meal_plan_model import MealPlanModel
from schemas.meal_plan_schema import CreateMealPlanResponse, MealPlanCreate, MealPlanRead, MealPlanUpdate, RetrieveMealPlanResponse, UpdateMealPlanResponse

from utils.helper_utils import HelperUtils

utils = HelperUtils()

class MealPlanController:
    def __init__(self) -> None:
        pass
    
    def create_meal_plan(self, meal_plan_data: MealPlanCreate, db: Session, authorization: str = Header(...)):
        """Creates a new meal plan for a user.

        Args:
            db (Session): Database session.
            meal_plan_data (MealPlanCreate): Data for the meal plan.
            authorization (str, optional): Authorization token from header.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
                
            token = authorization[7:]
            payload = utils.validate_JWT(token)
            
            existing_meal_plan = db.query(MealPlanModel).filter(
                MealPlanModel.user_id == payload['user_id']).first()
            
            if existing_meal_plan:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="User already has a meal plan."
                )
                
            # Convert meal plan to a JSON-serializable format
            meal_plan_dict = [
                day_meal_plan.dict() for day_meal_plan in meal_plan_data.meal_plan
            ]
            
            # Create an instance of MealPlanModel
            new_meal_plan = MealPlanModel(
                user_id=payload['user_id'],
                members={},
                meal_plan=meal_plan_dict
            )
            
            db.add(new_meal_plan)
            db.commit()
            db.refresh(new_meal_plan)
            
            return {
                "status": "success",
                "message": "Meal plan created successfully",
                "payload": new_meal_plan
            }
          
        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=CreateMealPlanResponse(
                    status="error",
                    message="Error when creating Meal plan!",
                    payload=str(e)
                ).dict()
            )

    
    def get_user_meal_plan(self, db: Session, authorization: str = Header(...)):
        """Creates a new meal plan for a user.

        Args:
            db (Session): Database session.
            meal_plan_data (MealPlanCreate): Data for the meal plan.
            authorization (str, optional): Authorization token from header.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
                
            token = authorization[7:]
            payload = utils.validate_JWT(token)
            
            meal_plan = db.query(MealPlanModel).filter(
                MealPlanModel.user_id == payload['user_id']).first()
            
            if not meal_plan:
                return JSONResponse(
                status_code=status.HTTP_404_NOT_FOUND,
                content=RetrieveMealPlanResponse(
                    status="error",
                    message="Error fetching Meal plan!",
                    payload="User does not have meal plan."
                ).dict()
            )
            
            return {
                "status": "success",
                "message": "User's meal plan",
                "payload": meal_plan
            }
            
        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=RetrieveMealPlanResponse(
                    status="error",
                    message="Error fetching Meal plan!",
                    payload=str(e)
                ).dict()
            )
            
            
    def update_user_meal_plan(self, db: Session, meal_plan_data: MealPlanUpdate, authorization: str):
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
                
            token = authorization[7:]
            payload = utils.validate_JWT(token)
            
            meal_plan_info = db.query(MealPlanModel).filter(
                MealPlanModel.user_id == payload['user_id']
            ).first()
            
            if not meal_plan_info:
                return JSONResponse(
                    status_code=status.HTTP_404_NOT_FOUND,
                    content=UpdateMealPlanResponse(
                        status="error",
                        message="Error fetching Meal plan!",
                        payload="User does not have a meal plan."
                    ).dict()
                )
                
            meal_plan_dict = [
                day_meal_plan.dict() for day_meal_plan in meal_plan_data.meal_plan
            ]
            
            if meal_plan_dict == meal_plan_info.meal_plan:
                return JSONResponse(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    content=UpdateMealPlanResponse(
                        status="error",
                        message="Error updating Meal plan!",
                        payload="No changes were made to the meal plan."
                    ).dict()
                )                
                
            meal_plan_info.meal_plan = meal_plan_dict
            
            # Convert to MealPlanRead model for the response
            updated_meal_plan = MealPlanRead(
                id=meal_plan_info.id,
                user_id=meal_plan_info.user_id,
                members=meal_plan_info.members,
                meal_plan=meal_plan_dict
            )
            
            # Update meal plan data
            
            db.commit()
            db.refresh(meal_plan_info)  
            
            
            return {
                "status": "success",
                "message": "Meal plan updated successfully",
                "payload": updated_meal_plan
            }

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=UpdateMealPlanResponse(
                    status="error",
                    message="Error updating Meal plan!",
                    payload=str(e)
                ).dict()
            )