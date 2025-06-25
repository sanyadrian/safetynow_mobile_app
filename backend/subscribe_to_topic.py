import boto3
import json

sns = boto3.client('sns', region_name='us-east-1')

# Replace with your Topic ARN
TOPIC_ARN = 'arn:aws:sns:us-east-1:370217917385:SafetyNow-Notifications'

# Replace with your Endpoint ARN (from register_device_token.py)
ENDPOINT_ARN = 'YOUR_ENDPOINT_ARN_HERE'

try:
    # Subscribe the endpoint to the topic
    response = sns.subscribe(
        TopicArn=TOPIC_ARN,
        Protocol='application',
        Endpoint=ENDPOINT_ARN
    )
    print("✅ Successfully subscribed to topic!")
    print("Subscription ARN:", response['SubscriptionArn'])
    
except Exception as e:
    print(f"❌ Error subscribing to topic: {e}")
    print("\n💡 Make sure:")
    print("1. You have created the SNS Topic 'SafetyNow-Notifications'")
    print("2. You're using the correct Topic ARN")
    print("3. You have a valid Endpoint ARN") 