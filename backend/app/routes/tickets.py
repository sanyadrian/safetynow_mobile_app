from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal
from fastapi.security import OAuth2PasswordBearer
from app.token import verify_access_token

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
    payload = verify_access_token(token)
    if payload is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return payload["user_id"]

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
        message=ticket.message,
        user_id=user_id
    )
    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)
    return {"message": "Ticket submitted successfully", "ticket_id": new_ticket.id}
