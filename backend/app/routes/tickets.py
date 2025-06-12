from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal, engine
from fastapi.security import OAuth2PasswordBearer
from app.jwt_token import verify_token
import msal
import requests
import os
from dotenv import load_dotenv

load_dotenv()

# Create tables
models.Base.metadata.create_all(bind=engine)

router = APIRouter(
    prefix="/ticket",
    tags=["ticket"]
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(token: str = Depends(oauth2_scheme)):
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return payload["user_id"]

def get_access_token():
    try:
        response = requests.post(
            "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            data={
                "client_id": os.getenv("AZURE_CLIENT_ID"),
                "client_secret": os.getenv("AZURE_CLIENT_SECRET"),
                "scope": "https://graph.microsoft.com/.default",
                "grant_type": "client_credentials"
            }
        )
        response.raise_for_status()
        return response.json()["access_token"]
    except Exception as e:
        print(f"Error getting access token: {e}")
        return None

def send_ticket_email(ticket: schemas.TicketCreate):
    access_token = get_access_token()
    if not access_token:
        print("Failed to get access token, skipping email send")
        return
    
    sender_email = os.getenv('AZURE_SENDER_EMAIL')
    recipient_email = os.getenv('AZURE_SENDER_EMAIL')
    
    email_body = f"""
    New Safety Ticket Received:
    
    From: {ticket.name}
    Email: {ticket.email}
    Phone: {ticket.phone}
    Topic: {ticket.topic}
    
    Message:
    {ticket.message}
    """
    
    email_data = {
        "message": {
            "subject": f"New Safety Ticket: {ticket.topic}",
            "body": {
                "contentType": "Text",
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
        print(f"Attempting to send email from {sender_email} to {recipient_email}")
        response = requests.post(
            f"https://graph.microsoft.com/v1.0/users/{sender_email}/sendMail",
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            },
            json=email_data
        )
        response.raise_for_status()
        print("Email sent successfully")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")
        if hasattr(e, 'response'):
            print(f"Response content: {e.response.content}")

@router.post("/")
def create_ticket(
    ticket: schemas.TicketCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    new_ticket = models.Ticket(
        name=ticket.name,
        email=ticket.email,
        phone=ticket.phone,
        topic=ticket.topic,
        message=ticket.message,
        user_id=user_id
    )
    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)
    
    send_ticket_email(ticket)
    
    return {"message": "Ticket submitted successfully", "ticket_id": new_ticket.id}
