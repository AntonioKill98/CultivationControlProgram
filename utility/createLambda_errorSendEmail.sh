#!/bin/bash

# Define constants
LAMBDA_NAME="errorSendEMail"
ZIP_FILE="errorSendEMail.zip"
LAMBDA_PY_FILE="$LAMBDA_NAME.py"
HANDLER="$LAMBDA_NAME.lambda_handler"
ROLE_ARN="arn:aws:iam::000000000000:role/lambdarole"
QUEUE_ARN="arn:aws:sqs:us-east-2:000000000000:Errors"
ENDPOINT="http://localhost:4566"

# Check if the zip file exists, and delete if present
if [ -f "$ZIP_FILE" ]; then
  echo "$ZIP_FILE already exists, removing..."
  rm $ZIP_FILE
fi

echo "Creating $ZIP_FILE..."
cd settings/
zip -r ../$ZIP_FILE $LAMBDA_PY_FILE
cd ..

# Add the file secrets.json to the zip file
echo "Adding secrets.json to the zip..."
zip -g $ZIP_FILE secrets.json

# Verify zip creation
if [ ! -f "$ZIP_FILE" ]; then
  echo "Error: $ZIP_FILE was not created."
  exit 1
fi

# Create the Lambda function
echo "Creating the Lambda function $LAMBDA_NAME..."
aws lambda create-function --function-name $LAMBDA_NAME \
  --zip-file fileb://$ZIP_FILE \
  --handler $HANDLER \
  --runtime python3.10 \
  --role $ROLE_ARN \
  --endpoint-url=$ENDPOINT

# Create event source mapping for the Errors SQS queue
echo "Creating event source mapping between $LAMBDA_NAME and Errors queue..."
aws lambda create-event-source-mapping --function-name $LAMBDA_NAME \
  --batch-size 5 \
  --maximum-batching-window-in-seconds 60 \
  --event-source-arn $QUEUE_ARN \
  --endpoint-url=$ENDPOINT

echo "Lambda function $LAMBDA_NAME configured successfully."