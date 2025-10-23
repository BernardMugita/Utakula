# connect.py
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Create the SQLAlchemy engine
engine = create_engine(DATABASE_URL)

# Create a configured "Session" class
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Test the connection
with engine.connect() as connection:
    result = connection.execute(text('SELECT "Database connection successful"'))
    print(result.all())
