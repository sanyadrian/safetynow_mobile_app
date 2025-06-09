from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models
from app.dependencies import get_current_user 
import os
import uuid
import boto3
from botocore.exceptions import BotoCoreError, NoCredentialsError

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
        s3 = boto3.client("s3")
        bucket_name = os.getenv("S3_BUCKET_NAME")
        if not bucket_name:
            raise HTTPException(status_code=500, detail="S3_BUCKET_NAME not set in environment")
        # Generate a unique filename
        file_ext = os.path.splitext(file.filename)[-1] or ".jpg"
        unique_filename = f"profile-images/{uuid.uuid4()}_{current_user.id}{file_ext}"
        # Upload to S3
        s3.upload_fileobj(file.file, bucket_name, unique_filename, ExtraArgs={"ACL": "public-read"})
        s3_url = f"https://{bucket_name}.s3.amazonaws.com/{unique_filename}"
        # Save URL to user profile
        current_user.profile_image = s3_url
        db.commit()
        db.refresh(current_user)
        return {"profile_image": s3_url}
    except (BotoCoreError, NoCredentialsError) as e:
        print(f"S3 error: {e}")
        raise HTTPException(status_code=500, detail=f"S3 error: {str(e)}")
    except Exception as e:
        print(f"Upload error: {e}") 
        raise HTTPException(status_code=500, detail=str(e))

