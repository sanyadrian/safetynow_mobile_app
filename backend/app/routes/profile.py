from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models
from app.dependencies import get_current_user 
import os
import shutil
from pathlib import Path

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
    try:
        # Create directory if it doesn't exist
        upload_dir = Path("app/static/profile_images")
        upload_dir.mkdir(parents=True, exist_ok=True)

        # Generate filename
        filename = f"profile_{current_user.id}.jpg"
        filepath = upload_dir / filename

        # Save the file
        with open(filepath, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Update user profile image path
        relative_path = f"/static/profile_images/{filename}"
        current_user.profile_image = relative_path
        db.commit()
        db.refresh(current_user)

        return {"profile_image": relative_path}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

