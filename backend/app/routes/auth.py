# app/routes/auth.py
from fastapi import status
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal, engine
from app.jwt_token import create_access_token

from passlib.context import CryptContext

# Create tables
models.Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    # Check if email already exists
    db_email = db.query(models.User).filter(models.User.email == user.email).first()
    if db_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Check if username already exists (case-insensitive)
    db_user = db.query(models.User).filter(models.User.username.ilike(user.username)).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")

    # Always store username as lowercase
    username = user.username.lower()

    # Create user
    hashed_password = pwd_context.hash(user.password)
    new_user = models.User(
        username=username,
        email=user.email,
        phone=user.phone,
        hashed_password=hashed_password
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

@router.post("/login")
def login(user_credentials: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.username == user_credentials.username).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid Credentials")
    
    if not pwd_context.verify(user_credentials.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Invalid Credentials")
    
    access_token = create_access_token(data={"user_id": user.id})

    return {"access_token": access_token, 
            "token_type": "bearer", 
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "phone": user.phone,
                "profile_image": user.profile_image
            }
    }