from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.token import verify_access_token
from app import models

router = APIRouter(
    prefix="/talks",
    tags=["talks"]
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

@router.get("/")
def get_talks(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    return db.query(models.Talk).all()


@router.get("/{talk_id}")
def get_talk_by_id(
    talk_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    talk = db.query(models.Talk).filter(models.Talk.id == talk_id).first()
    if not talk:
        raise HTTPException(status_code=404, detail="Talk not found")
    return talk

