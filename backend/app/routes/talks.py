from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
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
def get_talks_by_hazard(
    hazard: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    language: str = Query(None, description="Language code to filter talks")
):
    query = db.query(models.Talk).filter(models.Talk.hazard == hazard)
    if language:
        query = query.filter(models.Talk.language == language)
    talks = query.all()
    return [
        {
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "description": t.description,
            "hazard": t.hazard,
            "industry": t.industry,
            "language": t.language,
            "related_title": t.related_title
        }
        for t in talks
    ]

@router.get("/by_industry/{industry}")
def get_talks_by_industry(
    industry: str,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    language: str = Query(None, description="Language code to filter talks")
):
    query = db.query(models.Talk).filter(models.Talk.industry == industry)
    if language:
        query = query.filter(models.Talk.language == language)
    talks = query.all()
    return [
        {
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "description": t.description,
            "hazard": t.hazard,
            "industry": t.industry,
            "language": t.language,
            "related_title": t.related_title
        }
        for t in talks
    ]

@router.get("/")
def get_talks(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    language: str = Query(None, description="Language code to filter talks")
):
    query = db.query(models.Talk)
    if language:
        query = query.filter(models.Talk.language == language)
    talks = query.all()
    # Return all fields, including language and related_title
    return [
        {
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "description": t.description,
            "hazard": t.hazard,
            "industry": t.industry,
            "language": t.language,
            "related_title": t.related_title
        }
        for t in talks
    ]

@router.get("/popular")
def get_popular_talks(
    limit: int = 5,
    language: str = Query("en", description="Language code to filter popular talks"),
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Aggregate likes by related_title
    subq = db.query(
        models.Talk.related_title,
        func.count(models.TalkLike.id).label('like_count')
    ).outerjoin(
        models.TalkLike, models.Talk.id == models.TalkLike.talk_id
    ).group_by(
        models.Talk.related_title
    ).subquery()

    # Join to get a representative talk for each related_title in the requested language
    popular_talks = db.query(
        models.Talk,
        subq.c.like_count
    ).join(
        subq, models.Talk.related_title == subq.c.related_title
    ).filter(
        models.Talk.language == language
    ).order_by(
        subq.c.like_count.desc()
    ).limit(limit).all()

    result = []
    for talk, like_count in popular_talks:
        talk_dict = {
            "id": talk.id,
            "title": talk.title,
            "category": talk.category,
            "description": talk.description,
            "hazard": talk.hazard,
            "industry": talk.industry,
            "language": talk.language,
            "related_title": talk.related_title,
            "like_count": like_count
        }
        result.append(talk_dict)

    return result

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

@router.post("/{talk_id}/like")
def like_talk(
    talk_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Check if talk exists
    talk = db.query(models.Talk).filter(models.Talk.id == talk_id).first()
    if not talk:
        raise HTTPException(status_code=404, detail="Talk not found")
    related_title = talk.related_title

    # Find all talks with this related_title
    related_talk_ids = [t.id for t in db.query(models.Talk).filter(models.Talk.related_title == related_title).all()]

    # Check if already liked (by any talk in this group)
    existing_like = db.query(models.TalkLike).filter(
        models.TalkLike.talk_id.in_(related_talk_ids),
        models.TalkLike.user_id == current_user
    ).first()

    if existing_like:
        db.delete(existing_like)
        db.commit()
        return {"message": "Talk unliked successfully"}

    # Like the current talk (could also pick the first in group)
    new_like = models.TalkLike(talk_id=talk_id, user_id=current_user)
    db.add(new_like)
    db.commit()
    return {"message": "Talk liked successfully"}

@router.get("/{talk_id}/likes")
def get_talk_likes(
    talk_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Check if talk exists
    talk = db.query(models.Talk).filter(models.Talk.id == talk_id).first()
    if not talk:
        raise HTTPException(status_code=404, detail="Talk not found")
    related_title = talk.related_title
    related_talk_ids = [t.id for t in db.query(models.Talk).filter(models.Talk.related_title == related_title).all()]

    # Get like count for all translations
    like_count = db.query(func.count(models.TalkLike.id)).filter(
        models.TalkLike.talk_id.in_(related_talk_ids)
    ).scalar()

    # Check if current user has liked any translation
    user_liked = db.query(models.TalkLike).filter(
        models.TalkLike.talk_id.in_(related_talk_ids),
        models.TalkLike.user_id == current_user
    ).first() is not None

    return {
        "like_count": like_count,
        "user_liked": user_liked
    }

