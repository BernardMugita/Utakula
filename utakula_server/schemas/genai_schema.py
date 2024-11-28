from pydantic import BaseModel

class PromptBody(BaseModel):
    food_list: list[str]
    spices: list[str]
    narrative: str

class genAIResponse(BaseModel):
    status: str
    message: str
    payload: str
    
    class Config:
        from_attributes = True