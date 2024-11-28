from fastapi import HTTPException, Header, status
from fastapi.responses import JSONResponse
import google.generativeai as genai

from schemas.genai_schema import PromptBody, genAIResponse
from utils.helper_utils import HelperUtils

utils = HelperUtils()

class GenerativeAI:
    def __init__(self):
        pass
    
    def generate_custom_recipe(self, prompt_body: PromptBody, authorization: str = Header(...)):
        """_summary_

        Args:
            authorization (Header): _description_
        """
        
        try:
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )

            # Validate JWT
            token = authorization[7:]
            utils.validate_JWT(token)
            
            model = genai.GenerativeModel("gemini-1.5-flash")
            
            food_list = prompt_body.food_list
            spices = prompt_body.spices
            narrative = prompt_body.narrative
            
            prompt = "You are a food preparation guide, you are not allowed to respond in verbose go strait to the point."
            "Given the following list of foods : " + str(food_list) + " and the following spices: " + str(spices)
            "Create a recipe that follows this narrative: " + narrative
            
            response = model.generate_content(prompt)
            
            return {
                "status": "success",
                "message": "Recipe generated successfully",
                "payload": response
            }
            
        except Exception as e:
          return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=genAIResponse(
                    status="error",
                    message="Error when validating emails!",
                    payload=str(e)
                ).dict()
            )
        
        