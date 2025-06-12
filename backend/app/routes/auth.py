# app/routes/auth.py
from fastapi import status
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal, engine
from app.jwt_token import create_access_token, verify_access_token
from app.routes.tickets import get_access_token
from pydantic import BaseModel
import boto3
import os

from passlib.context import CryptContext
from datetime import datetime, timedelta
import random
import string
import requests

# Create tables
models.Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = verify_access_token(token)
        user_id: int = payload.get("user_id")
        if user_id is None:
            raise credentials_exception
    except:
        raise credentials_exception
        
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if user is None:
        raise credentials_exception
        
    return user

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_email = db.query(models.User).filter(models.User.email == user.email).first()
    if db_email:
        raise HTTPException(status_code=400, detail="Email already registered")

    db_user = db.query(models.User).filter(models.User.username.ilike(user.username)).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")

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

def generate_reset_code():
    return ''.join(random.choices(string.digits, k=6))

@router.post("/forgot-password")
async def forgot_password(request: schemas.PasswordResetRequest, db: Session = Depends(get_db)):
    # Check if user exists
    user = db.query(models.User).filter(models.User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    code = generate_reset_code()
    expires_at = datetime.utcnow() + timedelta(minutes=15)


    reset_request = models.PasswordReset(
        email=request.email,
        code=code,
        expires_at=expires_at
    )
    db.add(reset_request)
    db.commit()

 
    access_token = get_access_token()
    if not access_token:
        db.delete(reset_request)
        db.commit()
        raise HTTPException(status_code=500, detail="Failed to get access token for email service")

    sender_email = os.getenv('AZURE_SENDER_EMAIL')
    recipient_email = request.email

    email_body = f"""
    <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #007bff;">Password Reset Request</h2>
                <p>Hello,</p>
                <p>We received a request to reset your password. Use the following code to reset your password:</p>
                <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0;">
                    <h1 style="color: #007bff; margin: 0; font-size: 32px;">{code}</h1>
                </div>
                <p>This code will expire in 15 minutes.</p>
                <p>If you didn't request this reset, please ignore this email.</p>
                <hr style="border: 1px solid #eee; margin: 20px 0;">
                <p style="color: #666; font-size: 12px;">This is an automated message, please do not reply to this email.</p>
            </div>
        </body>
    </html>
    """

    email_data = {
        "message": {
            "subject": "SafetyNow - Password Reset Code",
            "body": {
                "contentType": "HTML",
                "content": email_body
            },
            "toRecipients": [
                {
                    "emailAddress": {
                        "address": recipient_email
                    }
                }
            ]
        }
    }

    try:
        response = requests.post(
            f"https://graph.microsoft.com/v1.0/users/{sender_email}/sendMail",
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            },
            json=email_data
        )
        response.raise_for_status()
    except Exception as e:
        db.delete(reset_request)
        db.commit()
        raise HTTPException(status_code=500, detail="Failed to send reset code email")

    return {"message": "Reset code sent to your email"}

@router.post("/verify-reset-code")
def verify_reset_code(request: schemas.PasswordResetVerify, db: Session = Depends(get_db)):
    reset_request = db.query(models.PasswordReset)\
        .filter(models.PasswordReset.email == request.email)\
        .filter(models.PasswordReset.is_used == False)\
        .filter(models.PasswordReset.expires_at > datetime.utcnow())\
        .order_by(models.PasswordReset.created_at.desc())\
        .first()

    if not reset_request:
        raise HTTPException(status_code=400, detail="Invalid or expired reset code")

    if reset_request.code != request.code:
        raise HTTPException(status_code=400, detail="Invalid reset code")

    return {"message": "Code verified successfully"}

@router.post("/reset-password")
def reset_password(request: schemas.PasswordReset, db: Session = Depends(get_db)):
    reset_request = db.query(models.PasswordReset)\
        .filter(models.PasswordReset.email == request.email)\
        .filter(models.PasswordReset.is_used == False)\
        .filter(models.PasswordReset.expires_at > datetime.utcnow())\
        .order_by(models.PasswordReset.created_at.desc())\
        .first()

    if not reset_request:
        raise HTTPException(status_code=400, detail="Invalid or expired reset code")

    if reset_request.code != request.code:
        raise HTTPException(status_code=400, detail="Invalid reset code")

    user = db.query(models.User).filter(models.User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.hashed_password = pwd_context.hash(request.new_password)
    reset_request.is_used = True
    db.commit()

    return {"message": "Password reset successful"}

class DeleteAccountRequest(BaseModel):
    password: str

@router.delete("/delete-account")
def delete_account(
    request: DeleteAccountRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Verify password
    if not pwd_context.verify(request.password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid password"
        )
    
    # Delete user's data
    # Delete profile image from S3 if exists
    if current_user.profile_image:
        try:
            s3 = boto3.client("s3")
            bucket_name = os.getenv("S3_BUCKET_NAME")
            if bucket_name:
                # Extract the key from the URL
                key = current_user.profile_image.split(f"https://{bucket_name}.s3.amazonaws.com/")[-1]
                s3.delete_object(Bucket=bucket_name, Key=key)
        except Exception as e:
            print(f"Error deleting profile image: {e}")
    
    # Delete user's history
    db.query(models.TalkHistory).filter(models.TalkHistory.user_id == current_user.id).delete()
    
    # Delete user's likes
    db.query(models.TalkLike).filter(models.TalkLike.user_id == current_user.id).delete()
    db.query(models.ToolLike).filter(models.ToolLike.user_id == current_user.id).delete()
    
    # Delete user's tickets
    db.query(models.Ticket).filter(models.Ticket.user_id == current_user.id).delete()
    
    # Finally, delete the user
    db.delete(current_user)
    db.commit()
    
    return {"message": "Account deleted successfully"}