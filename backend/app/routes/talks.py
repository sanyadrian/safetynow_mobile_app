from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.jwt_token import verify_access_token
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

@router.get("/hazards")
def get_unique_hazards(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    hazards = db.query(models.Talk.hazard).distinct().all()
    return [h[0] for h in hazards if h[0]]

@router.get("/industries")
def get_unique_industries(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    industries = db.query(models.Talk.industry).distinct().all()
    return [i[0] for i in industries if i[0]]

@router.get("/by_hazard/{hazard}")
def get_talks_by_hazard(hazard: str, db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    talks = db.query(models.Talk).filter(models.Talk.hazard == hazard).all()
    return talks

@router.get("/by_industry/{industry}")
def get_talks_by_industry(industry: str, db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    talks = db.query(models.Talk).filter(models.Talk.industry == industry).all()
    return talks

@router.get("/")
def get_talks(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    return db.query(models.Talk).all()

@router.get("/{talk_id}")
def get_talk_by_id(
    talk_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    talk = db.query(models.Talk).filter(models.Talk.id == talk_id).first()
    if not talk:
        raise HTTPException(status_code=404, detail="Talk not found")
    return talk

