from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.dependencies import get_current_user
from app.models import User
import boto3
import json

router = APIRouter(prefix="/register-device-token", tags=["device-tokens"])

# Initialize SNS client
sns = boto3.client('sns', region_name='us-east-1')

# Update these with your actual ARNs
PLATFORM_APPLICATION_ARN = 'arn:aws:sns:us-east-1:370217917385:app/APNS/MyApp-iOS'  # Your actual platform app ARN
TOPIC_ARN = 'arn:aws:sns:us-east-1:370217917385:SafetyNow-Notifications'  # Your topic ARN

class DeviceTokenRequest(BaseModel):
    device_token: str

class NotificationRequest(BaseModel):
    title: str
    body: str

@router.post("/")
async def register_device_token(
    request: DeviceTokenRequest,
    current_user: User = Depends(get_current_user)
):
    try:
        # Register device token with SNS
        response = sns.create_platform_endpoint(
            PlatformApplicationArn=PLATFORM_APPLICATION_ARN,
            Token=request.device_token,
            CustomUserData=str(current_user.id)  # Store user ID for reference
        )
        
        endpoint_arn = response['EndpointArn']
        
        # Subscribe the endpoint to the topic for broadcasting
        try:
            sns.subscribe(
                TopicArn=TOPIC_ARN,
                Protocol='application',
                Endpoint=endpoint_arn
            )
            print(f"User {current_user.id} subscribed to topic successfully")
        except Exception as topic_error:
            print(f"Warning: Could not subscribe to topic: {topic_error}")
        
        # TODO: Store the endpoint ARN in your database
        # You can add a table to store user_id -> endpoint_arn mapping
        
        return {
            "message": "Device token registered successfully",
            "endpoint_arn": endpoint_arn
        }
        
    except Exception as e:
        print(f"Error registering device token: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to register device token")

@router.post("/send-notification")
async def send_notification_to_all_users(
    request: NotificationRequest,
    current_user: User = Depends(get_current_user)
):
    """Send notification to all users subscribed to the topic"""
    try:
        message = {
            "APNS": json.dumps({
                "aps": {
                    "alert": {
                        "title": request.title,
                        "body": request.body
                    },
                    "sound": "default",
                    "badge": 1
                }
            })
        }
        
        response = sns.publish(
            TopicArn=TOPIC_ARN,
            MessageStructure='json',
            Message=json.dumps(message)
        )
        
        return {
            "message": "Notification sent to all users successfully",
            "message_id": response['MessageId']
        }
        
    except Exception as e:
        print(f"Error sending notification: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to send notification") 