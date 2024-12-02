from fastapi import HTTPException, Header, status
from fastapi.responses import JSONResponse
import google.generativeai as genai
import os

from schemas.genai_schema import PromptBody, GenAIResponse
from utils.helper_utils import HelperUtils

utils = HelperUtils()



class GenerativeAI:
    def __init__(self):
        pass
    
    def generate_custom_recipe(self, prompt_body: PromptBody, authorization: str = Header(...)):
        """Generate a custom recipe based on user input."""

        try:
            # Validate Authorization Header
            if not authorization.startswith("Bearer "):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Authorization header must start with 'Bearer '"
                )

            # Validate JWT
            token = authorization[7:]
            utils.validate_JWT(token)
            
            # Generate Content
            genai.configure(api_key=os.environ['API_KEY'])
            model = genai.GenerativeModel("gemini-1.5-flash", generation_config={"response_mime_type": "application/json"})
            
            food_list = prompt_body.food_list
            spices = prompt_body.spices
            narrative = prompt_body.narrative
            
            prompt = (
                "You are a neal assistant. Respond in a JSON with key value pair: recipe,"
                "name, ingredients and instructions in steps."
                f"Given the following list of foods: {food_list} and the following spices: {spices}. "
                f"Create a recipe that follows this narrative: {narrative}"
            )

            response = model.generate_content(prompt)
            
            return {
                "status": "success",
                "message": "Recipe generated successfully",
                "payload": response.to_dict()
            }
            
        except Exception as e:
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=GenAIResponse(
                    status="error",
                    message="Error when generating custom recipe",
                    payload=str(e)
                ).dict()
            )
