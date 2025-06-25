import boto3
import json

sns = boto3.client('sns', region_name='us-east-1')

# Replace with your Platform Application ARN
PLATFORM_APPLICATION_ARN = 'arn:aws:sns:us-east-1:370217917385:app/APNS/MyApp-iOS'

# Replace with your actual device token from the app
# Device token should be ~64 characters of hex (like: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef)
DEVICE_TOKEN = 'YOUR_ACTUAL_DEVICE_TOKEN_HERE'

# Validate device token format
if DEVICE_TOKEN == 'YOUR_ACTUAL_DEVICE_TOKEN_HERE':
    print("❌ Please replace DEVICE_TOKEN with your actual device token from the app")
    print("💡 The device token should be ~64 characters of hexadecimal")
    exit(1)

if len(DEVICE_TOKEN) > 400:
    print(f"❌ Device token too long: {len(DEVICE_TOKEN)} characters")
    print("💡 iOS device tokens must be no more than 400 hexadecimal characters")
    exit(1)

try:
    response = sns.create_platform_endpoint(
        PlatformApplicationArn=PLATFORM_APPLICATION_ARN,
        Token=DEVICE_TOKEN
    )
    print("✅ Endpoint created successfully!")
    print("Endpoint ARN:", response['EndpointArn'])
    print("\n📝 Copy this Endpoint ARN to use in subscribe_to_topic.py")
    
except Exception as e:
    print(f"❌ Error creating endpoint: {e}")
    print("\n💡 Make sure:")
    print("1. You're using a real device token from your App Store app")
    print("2. The device token is in correct hexadecimal format")
    print("3. AWS credentials are properly configured") 