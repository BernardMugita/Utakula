from fastapi import Body, HTTPException, status, Depends, Header
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from controllers.calorie_controller import CalorieController
from models.calorie_model import CalorieModel
from models.food_model import FoodModel
from schemas.calorie_schema import CalorieBreakdownSchema, CalorieRead
from schemas.food_schema import CreateFoodResponse, DeleteFoodResponse, FoodCreate, FoodDelete, FoodGet, FoodRead, FoodUpdate, RetrieveFoodResponse, UpdateFoodResponse
from utils.helper_utils import HelperUtils

utils = HelperUtils()
calorie_controller = CalorieController()

class FoodController:
    def __init__(self) -> None:
        pass
    
    def add_new_food(self, food: FoodCreate, db: Session, authorization: str = Header(...)):
        """_summary_

        Args:
            food (FoodCreate): _description_
            db (Session): _description_
            authorization (str, optional): _description_. Defaults to Header(...).
        """
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:] 
            payload = utils.validate_JWT(token)  
            
            if payload['role'] != "admin":
                JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content=CreateFoodResponse(
                    status="error",
                    message="Failed to add food",
                    payload=f"You are not authorized to access this route"
                ).dict()
            )
            
            existing_food = db.query(FoodModel).filter(
                FoodModel.name == food.name
            ).first()
            
            if existing_food:
                JSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content=CreateFoodResponse(
                    status="error",
                    message="Failed to add food",
                    payload=f"Food already exists"
                ).dict()
            )
                
            new_food = FoodModel(
                name=food.name,
                image_url=food.image_url,
                macro_nutrient=food.macro_nutrient,
                meal_type = food.meal_type
            )
            
            db.add(new_food)
            db.commit()
            db.refresh(new_food)
            
            return {
                "status": "success",
                "message": "Food added.",
                "payload": new_food
            }
          
        except Exception as e:
          return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=CreateFoodResponse(
                    status="error",
                    message="Error when adding food!",
                    payload=f"{str(e)}"
                ).dict()
            )
          
    def get_all_foods(self, db: Session, authorization: str = Header(...)):
        """Retrieve all foods along with their calorie breakdown.

        Args:
            db (Session): Database session.
            authorization (str, optional): Authorization header.

        Raises:
            HTTPException: If authorization fails.

        Returns:
            dict: A dictionary containing the status, message, and list of foods with calorie breakdown.
        """
        try:
            # Verify authorization
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )

            token = authorization[7:]
            utils.validate_JWT(token)

            # Retrieve all foods
            foods = db.query(FoodModel).all()
            
            # Create a list to store foods with calorie breakdown
            food_list = []
            
            for food in foods:
                # Retrieve calorie data for each food
                food_calories = db.query(CalorieModel).filter(CalorieModel.food_id == str(food.id)).first()
                
                # Create calorie breakdown data if available
                calorie_data = CalorieRead(
                    id=food_calories.id if food_calories else '',
                    food_id=food_calories.food_id if food_calories else '',
                    total=food_calories.total if food_calories else 0,
                    breakdown=food_calories.breakdown if food_calories else {}
                )

                # Append each food with calorie data to the food list
                food_list.append(FoodRead(
                    id=food.id,
                    image_url=food.image_url,
                    name=food.name,
                    macro_nutrient=food.macro_nutrient,
                    meal_type=food.meal_type,
                    calorie_breakdown=calorie_data
                ))

            return {
                "status": "success",
                "message": "List of all foods",
                "payload": food_list
            }
        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=RetrieveFoodResponse(
                    status="error",
                    message="Error when retrieving foods",
                    payload=str(e)
                ).dict()
            )

    
    
    def get_food_by_id(self, db: Session, food_data: FoodGet = Body(...), authorization: str = Header(...)):
        """_summary_

        Args:
            db (Session): _description_
            authorization (str, optional): _description_. Defaults to Header(...).

        Raises:
            HTTPException: _description_
            HTTPException: _description_
            HTTPException: _description_

        Returns:
            _type_: _description_
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:] 
            utils.validate_JWT(token)  

            # If token is valid, proceed to get the food by ID
            single_food = db.query(FoodModel).filter(FoodModel.id == str(food_data.id)).first()
            
            if not single_food:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="food not found"
                )
                
            food_calories = db.query(CalorieModel).filter(CalorieModel.food_id ==  str(single_food.id)).first()
            
            print(food_calories)
            
            food = FoodRead(
                id=single_food.id,
                image_url=single_food.image_url,
                name=single_food.name,
                macro_nutrient=single_food.macro_nutrient,
                meal_type=single_food.meal_type,
                calorie_breakdown=CalorieRead(
                    id=food_calories.id,
                    food_id=food_calories.food_id,
                    total=food_calories.total,
                    breakdown=food_calories.breakdown
                )
            )
                
            return {
                    "status": "success",
                    "message": "Food details.",
                    "payload": food
                }  
        except Exception as e:
           return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=RetrieveFoodResponse(
                    status="error",
                    message="Error when fetching food",
                    payload= f"{str(e)}",
                ).dict()
            )
           
           
    def edit_food_details(self, db: Session, authorization: str = Header(...), food_data: FoodUpdate = Body(...)):
        """Edit the food's details.

        Args:
            db (Session): Database session.
            authorization (str): Authorization header.
            food_data (FoodUpdate): Data to update in the food.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:] 
            utils.validate_JWT(token)

            # Get the food by ID from the validated JWT payload
            food = db.query(FoodModel).filter(FoodModel.id == str(food_data.id)).first()
            if not food:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="food not found"
                )
            
            if food_data.image_url is not None:
                food.image_url = food_data.image_url
            if food_data.name is not None:
                food.name = food_data.name
            if food_data.macro_nutrient is not None:
                food.macro_nutrient = food_data.macro_nutrient
            if food_data.meal_type is not None:
                food.meal_type = food_data.meal_type

            # Commit the changes to the database
            db.commit()
            db.refresh(food)  # Refresh the instance to get updated data

            # Return a response indicating success
            return {
                "status": "success",
                "message": "food details updated successfully",
                "payload": food
            }

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=UpdateFoodResponse(
                    status="error",
                    message="Error editing food",
                    payload=str(e)
                ).dict()
            )
            
            
    def delete_food_details(self, db: Session, food_data: FoodDelete = Body(...), authorization: str = Header(...)):
        """Delete the food's food.

        Args:
            db (Session): Database session.
            authorization (str): Authorization header.
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            token = authorization[7:] 
            utils.validate_JWT(token)  

            food = db.query(FoodModel).filter(FoodModel.id == str(food_data.id)).first()
            if not food:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="food not found"
                )
            
            db.delete(food)
            db.commit() 
            
            return {
                "status": "success",
                "payload": "food deleted successfully",
            }

        except Exception as e:
            db.rollback() 
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=DeleteFoodResponse(
                    status="error",
                    payload=f"Error deleting food: {str(e)}",
                ).dict()
            )
    