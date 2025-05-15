from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models
from app.dependencies import get_current_user 
import os
import shutil

router = APIRouter(
    prefix="/profile",
    tags=["profile"]
)

@router.post("/upload-image")
def upload_profile_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    directory = "/static/profile_images"
    os.makedirs(directory, exist_ok=True)

    filename = f"profile_{current_user.id}.jpg"
    filepath = os.path.join(directory, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    relative_path = f"/static/profile_images/{filename}"
    current_user.profile_image = relative_path

    db.commit()
    db.refresh(current_user)

    return {"profile_image": relative_path}

