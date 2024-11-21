from fastapi import FastAPI
from routes.auth_routes import router as auth_router
from routes.user_routes import router as user_router
from routes.food_routes import router as food_router
from routes.calorie_routes import router as calorie_router
from routes.meal_plan_routes import router as meal_plan_router
from routes.invitation_routes import router as invitation_router

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Where is the food"}

# Include routers with prefixes
app.include_router(auth_router, prefix='/utakula/validate')
app.include_router(user_router, prefix='/utakula/jamii')
app.include_router(food_router, prefix='/utakula/chakula')
app.include_router(calorie_router, prefix='/utakula/mawowowo')
app.include_router(meal_plan_router, prefix='/utakula/ratiba')
app.include_router(invitation_router, prefix='/utakula/ombi')  

