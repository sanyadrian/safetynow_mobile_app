import boto3

sns = boto3.client('sns', region_name='us-east-1')

# Replace with your Platform Application ARN and device token
PLATFORM_APPLICATION_ARN = 'arn:aws:sns:us-east-1:370217917385:app/APNS/MyApp-iOS'
DEVICE_TOKEN = 'YOUR_DEVICE_TOKEN_HERE'

response = sns.create_platform_endpoint(
    PlatformApplicationArn=PLATFORM_APPLICATION_ARN,
    Token=DEVICE_TOKEN
)
print("Endpoint ARN:", response['EndpointArn']) 