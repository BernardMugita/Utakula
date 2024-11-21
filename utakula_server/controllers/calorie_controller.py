from fastapi import HTTPException, Header, status
from fastapi.responses import JSONResponse
from models.calorie_model import CalorieModel
from schemas.calorie_schema import CalorieCreate, CalorieGet, CalorieRead, CalorieUpdate, CreateCalorieResponse, FetchCalorieResponse, UpdateCalorieResponse
from sqlalchemy.orm import Session
from utils.helper_utils import HelperUtils

utils = HelperUtils()


class CalorieController:
    def __init__(self) -> None:
        pass
    
    def add_new_calorie_data(self, calorie_data: CalorieCreate, db: Session, authorization: str = Header(...)):
        """Add new calorie data to the database.

        Args:
            calorie_data (CalorieCreate): The calorie data to be added.
            db (Session): Database session used for the operation.
            authorization (str): Authorization token or header for access control.
        """
        try:
            # Validate authorization header format
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )
            
            # Extract and validate JWT token
            token = authorization[7:]
            payload = utils.validate_JWT(token)  
            
            if payload['role'] != "admin":
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="You are not authorized to access this route"
            )
            
            # Check if calorie already exists
            existing_calorie = db.query(CalorieModel).filter(
                CalorieModel.food_id == calorie_data.food_id 
            ).first()
            
            if existing_calorie:
                return JSONResponse(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    content=CreateCalorieResponse(
                        status="error",
                        message="404",
                        payload="Calorie already exists"
                    ).dict()
                )
            
            calorie = CalorieModel(
                food_id=calorie_data.food_id,
                total=calorie_data.total,
                breakdown=calorie_data.breakdown.dict()
            )

            
            db.add(calorie) 
            db.commit()
            db.refresh(calorie)
            
            return {
                "status": "success",
                "message": "Calorie added",
                "payload": calorie
            }

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=CreateCalorieResponse(
                    status="error",
                    message="Error when adding Calorie!",
                    payload=f"{str(e)}"
                ).dict()
            )
            
    
    def get_all_calories(self, db: Session, authorization: str = Header(...)):
        """Fetches all calories data"""

        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )

            token = authorization[7:]
            utils.validate_JWT(token)

            # Fetch all CalorieModel instances
            calories = db.query(CalorieModel).all()

            # Convert each CalorieModel instance to a CalorieRead instance
            calorie_list = [{
                "id":calorie.id,
                "food_id":calorie.food_id,
                "total":calorie.total,
                "breakdown":calorie.breakdown               
            } for calorie in calories]

            # Return the response in the expected format
            return FetchCalorieResponse(
                status="success",
                message="List of all calories",
                payload=calorie_list  # Return list of calories
            ).dict()

        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=FetchCalorieResponse(
                    status="error",
                    message="Error when fetching Calories!",
                    payload=f"{str(e)}"
                ).dict()
            )
    
    def get_calorie_by_food_id(self, db: Session, calorie_data: CalorieGet ,authorization: str = Header(...)):
        """_summary_

        Args:
            db (Session): _description_
            calorie_data (CalorieGet): _description_
            authorization (str, optional): _description_. Defaults to Header(...).
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
            calorie = db.query(CalorieModel).filter(CalorieModel.food_id == str(calorie_data.food_id)).first()
                
            if not calorie:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="calorie not found"
                )
                    
            return {
                "status": "success",
                "message": "Food Calories.",
                "payload": calorie
            } 
        
        except Exception as e:
          return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content=FetchCalorieResponse(
                status="error",
                message="Error when fetching Calorie!",
                payload=f"{str(e)}"
            ).dict()
        )
          
    
    def update_calorie_info(self, db: Session, calorie_data: CalorieUpdate, authorization: str = Header(...)):
        """_summary_

        Args:
            db (Session): _description_
            calorie_data (CalorieUpdate): _description_
            authorization (str, optional): _description_. Defaults to Header(...).
        """
        
        try:
            if not authorization.startswith("Bearer "):
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail="Authorization header must start with 'Bearer '"
                    )
                
            token = authorization[7:] 
            utils.validate_JWT(token)

            # Get the calorie by ID from the validated JWT payload
            calorie = db.query(CalorieModel).filter(CalorieModel.id == str(calorie_data.id)).first()
            
            if not calorie:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="calorie not found"
                )
            
            if calorie_data.total is not None:
                calorie.total = calorie_data.total
            if calorie_data.breakdown is not None:
                calorie.breakdown = calorie_data.breakdown.dict()
                
            # Commit the changes to the database
            db.commit()
            db.refresh(calorie)  
            
            return {
                "status": "success",
                "message": "calorie details updated successfully",
                "payload": calorie
            }
        except Exception as e:
          return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=UpdateCalorieResponse(
                    status="error",
                    message=f"Error when updating Calorie.",
                    payload=str(e)
                ).dict()
            )