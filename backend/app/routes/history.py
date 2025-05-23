from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app import models, schemas
from app.database import SessionLocal
from fastapi.security import OAuth2PasswordBearer
from app.jwt_token import verify_access_token
from datetime import datetime

router = APIRouter(
    prefix="/history",
    tags=["history"]
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
def add_to_history(
    entry: schemas.TalkHistoryCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    new_entry = models.TalkHistory(
        user_id=user_id,
        talk_title=entry.talk_title,
        accessed_at=datetime.utcnow()
    )
    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)
    return {"message": "Talk added to history"}

@router.get("/")
def get_history(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    history = db.query(models.TalkHistory).filter(models.TalkHistory.user_id == user_id).all()
    return history

@router.get("/{history_id}")
def get_history_item(history_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    item = db.query(models.TalkHistory).filter(models.TalkHistory.id == history_id, models.TalkHistory.user_id == current_user).first()
    if not item:
        raise HTTPException(status_code=404, detail="History item not found")
    return item

@router.delete("/{history_id}")
def delete_history_item(
    history_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user)
):
    item = db.query(models.TalkHistory).filter(
        models.TalkHistory.id == history_id,
        models.TalkHistory.user_id == user_id
    ).first()
    if not item:
        raise HTTPException(status_code=404, detail="History item not found")
    db.delete(item)
    db.commit()
    return {"message": "History item deleted"}
