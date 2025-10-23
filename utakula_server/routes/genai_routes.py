
from fastapi import APIRouter, Depends, Header
from controllers.food_controller import FoodController
from connect import SessionLocal
from schemas.genai_schema import GenAIResponse, PromptBody
from sqlalchemy.orm import Session

from controllers.generative_ai_controller import GenerativeAI

 
router = APIRouter()
gen_ai_controller = GenerativeAI()
        
@router.post("/genai/custom_recipe", response_model=GenAIResponse)
async def create_food(
    prompt_body: PromptBody,
    authorization: str = Header(...)
):
    return gen_ai_controller.generate_custom_recipe(prompt_body, authorization)