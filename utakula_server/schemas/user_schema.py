import uuid
from pydantic import BaseModel, EmailStr

    
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

class UserRead(BaseModel):
    id: uuid.UUID  
    username: str
    role: str
    email: EmailStr
    
class UserAuthorize(BaseModel):
    username: str
    password: str

class SignedUser(BaseModel):
    id: str 
    username: str
    role: str
    
class AuthResponse(BaseModel):
    status: str
    message: str
    payload: str
    
class RegisterResponse(BaseModel):
    status: str
    message: str
    payload: UserRead | str
    
class UserUpdate(BaseModel):
    email: EmailStr
    
class RetrieveUserResponse(BaseModel):
    status: str
    message: str
    payload: UserRead | list[UserRead] | str
    
class UpdateAccountResponse(BaseModel):
    status: str
    message: str
    payload: UserRead | str
    
class DeleteAccountResponse(BaseModel):
    status: str
    payload: str
    
    class Config:
        from_attributes = True 
