from fastapi import HTTPException, status
import jwt
import os

class HelperUtils:
    def __init__(self) -> None:
        self.secret_key = os.getenv("ACCESS_SECRET")
        self.algorithm = "HS256"

    def validate_JWT(self, token: str):
        """_summary_

        Args:
            token (str): _description_

        Raises:
            HTTPException: _description_
            HTTPException: _description_

        Returns:
            _type_: _description_
        """
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload  
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.InvalidTokenError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )