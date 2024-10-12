#!/bin/bash

# If the zip file already exists, delete it
if [ -f "avgTempHum.zip" ]; then
  echo "The file avgTempHum.zip already exists, deleting it..."
  rm avgTempHum.zip
fi

# Create a zip file containing the Python script for the Lambda function
echo "Zipping the file avgTempHum.py..."
zip -r avgTempHum.zip settings/avgTempHum.py

# Check if the zip file was created successfully
if [ ! -f "avgTempHum.zip" ]; then
  echo "Error: The file avgTempHum.zip was not created successfully."
  exit 1
fi

# Create the Lambda function and save the ARN in targetLambda_avgTempHum.json
echo "Creating the Lambda function avgTempHum..."
ARN=$(aws lambda create-function --function-name avgTempHum \
  --zip-file fileb://avgTempHum.zip \
  --handler settings/avgTempHum.lambda_handler \
  --runtime python3.10 \
  --role arn:aws:iam::000000000000:role/lambdarole \
  --timeout 60 \
  --query 'FunctionArn' \
  --output text \
  --endpoint-url=http://localhost:4566)

# Check if the Lambda function was created successfully
if [ $? -eq 0 ]; then
  echo "Lambda function created successfully."

  # Save the ARN in targetLambda_avgTempHum.json
  echo "Saving the ARN in targetLambda_avgTempHum.json..."
  echo "[{\"Id\": \"1\", \"Arn\": \"$ARN\"}]" > ARN/targetLambda_avgTempHum.json
  echo "ARN saved successfully."
else
  echo "Error during Lambda function creation."
fi