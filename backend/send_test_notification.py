import boto3

sns = boto3.client('sns', region_name='us-east-1')

# Replace with your Endpoint ARN
ENDPOINT_ARN = 'YOUR_ENDPOINT_ARN_HERE'

message = {
    "APNS_SANDBOX": '{ "aps": { "alert": "Hello from SNS!", "sound": "default" } }'
}

sns.publish(
    TargetArn=ENDPOINT_ARN,
    MessageStructure='json',
    Message=str(message).replace("'", '"')  # Ensure JSON double quotes
)
print("Notification sent!") 