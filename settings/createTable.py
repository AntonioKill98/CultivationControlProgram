import boto3
import json
import os

# Configure DynamoDB on LocalStack
dynamodb = boto3.resource('dynamodb', endpoint_url="http://localhost:4566")

# Create DynamoDB table with streams enabled
table = dynamodb.create_table(
    TableName='Campi',
    KeySchema=[
        {
            'AttributeName': 'cultivationName',
            'KeyType': 'HASH'
        }
    ],
    AttributeDefinitions=[
        {
            'AttributeName': 'cultivationName',
            'AttributeType': 'S'
        }
    ],
    ProvisionedThroughput={
        'ReadCapacityUnits': 10,
        'WriteCapacityUnits': 10
    },
    StreamSpecification={
        'StreamEnabled': True,
        'StreamViewType': 'NEW_AND_OLD_IMAGES'
    }
)

print('Table', table, 'created with DynamoDB Streams enabled!')

# Retrieve the table status and Stream ARN
table_description = table.meta.client.describe_table(TableName='Campi')
stream_arn = table_description['Table']['LatestStreamArn']
print(f"DynamoDB Streams ARN: {stream_arn}")

# Save the ARN to the targetTable_Campi.json file
arn_data = [{"TableName": "Campi", "StreamArn": stream_arn}]
arn_file_path = os.path.join("ARN", "targetTable_Campi.json")

os.makedirs(os.path.dirname(arn_file_path), exist_ok=True)

with open(arn_file_path, 'w') as f:
    json.dump(arn_data, f, indent=4)

print(f"Stream ARN saved in {arn_file_path}")