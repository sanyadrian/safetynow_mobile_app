import boto3
import json

sns = boto3.client('sns', region_name='us-east-1')

# Replace with your Topic ARN
TOPIC_ARN = 'arn:aws:sns:us-east-1:370217917385:SafetyNow-Notifications'

# Message to send to all users
message = {
    "APNS": json.dumps({
        "aps": {
            "alert": {
                "title": "SafetyNow",
                "body": "New safety talk available! Check it out now."
            },
            "sound": "default",
            "badge": 1
        }
    })
}

try:
    # Publish message to topic (goes to all subscribers)
    response = sns.publish(
        TopicArn=TOPIC_ARN,
        MessageStructure='json',
        Message=json.dumps(message)
    )
    print("✅ Notification sent to all users!")
    print("Message ID:", response['MessageId'])
    print("\n📱 All subscribed devices should receive this notification")
    
except Exception as e:
    print(f"❌ Error sending to topic: {e}")
    print("\n💡 Make sure:")
    print("1. You have created the SNS Topic")
    print("2. You're using the correct Topic ARN")
    print("3. You have endpoints subscribed to the topic") 