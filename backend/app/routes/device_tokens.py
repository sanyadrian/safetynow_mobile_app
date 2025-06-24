from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.dependencies import get_current_user
from app.models import User
import boto3
import json

router = APIRouter(prefix="/register-device-token", tags=["device-tokens"])

# Initialize SNS client
sns = boto3.client('sns', region_name='us-east-1')
PRODUCTION_PLATFORM_ARN = 'arn:aws:sns:us-east-1:370217917385:app/APNS/YourApp-Production'  # Update this with your production ARN

class DeviceTokenRequest(BaseModel):
    device_token: str

@router.post("/")
async def register_device_token(
    request: DeviceTokenRequest,
    current_user: User = Depends(get_current_user)
):
    try:
        # Register device token with SNS
        response = sns.create_platform_endpoint(
            PlatformApplicationArn=PRODUCTION_PLATFORM_ARN,
            Token=request.device_token,
            CustomUserData=str(current_user.id)  # Store user ID for reference
        )
        
        endpoint_arn = response['EndpointArn']
        
        # TODO: Store the endpoint ARN in your database
        # You can add a table to store user_id -> endpoint_arn mapping
        
        return {
            "message": "Device token registered successfully",
            "endpoint_arn": endpoint_arn
        }
        
    except Exception as e:
        print(f"Error registering device token: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to register device token") 