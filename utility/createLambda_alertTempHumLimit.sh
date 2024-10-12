#!/bin/bash

# If the zip file already exists, delete it
if [ -f "alertTempHumLimit.zip" ]; then
  echo "The file alertTempHumLimit.zip already exists, deleting it..."
  rm alertTempHumLimit.zip
fi

# Create a zip file containing the contents of the alertTempHumLimit_package folder (where the dependencies are)
echo "Zipping the package contents..."
cd settings/alertTempHumLimit_package
zip -r ../../alertTempHumLimit.zip .
cd ../../

# Move to the "settings" directory to add the Python script to the root of the zip file
cd settings
echo "Adding alertTempHumLimit.py to the zip..."
zip -g ../alertTempHumLimit.zip alertTempHumLimit.py
cd ..

# Add the file secrets.json to the zip file
echo "Adding secrets.json to the zip..."
zip -g alertTempHumLimit.zip secrets.json

# Check if the zip file was created successfully
if [ ! -f "alertTempHumLimit.zip" ]; then
  echo "Error: The file alertTempHumLimit.zip was not created successfully."
  exit 1
fi

# Create the Lambda function and save the ARN in targetLambda_alertTempHumLimit.json
echo "Creating the Lambda function alertTempHumLimit..."
ARN=$(aws lambda create-function --function-name alertTempHumLimit \
  --zip-file fileb://alertTempHumLimit.zip \
  --handler alertTempHumLimit.lambda_handler \
  --runtime python3.10 \
  --role arn:aws:iam::000000000000:role/lambdarole \
  --timeout 60 \
  --query 'FunctionArn' \
  --output text \
  --endpoint-url=http://localhost:4566)

# Check if the Lambda function was created successfully
if [ $? -eq 0 ]; then
  echo "Lambda function created successfully."

  # Save the ARN in targetLambda_alertTempHumLimit.json
  echo "Saving the ARN in targetLambda_alertTempHumLimit.json..."
  echo "[{\"Id\": \"1\", \"Arn\": \"$ARN\"}]" > ARN/targetLambda_alertTempHumLimit.json
  echo "ARN saved successfully."

  # Retrieve the Stream ARN from the file ARN/targetTable_Campi.json
  STREAM_ARN=$(jq -r '.[0].StreamArn' ARN/targetTable_Campi.json)
  
  if [ -z "$STREAM_ARN" ]; then
    echo "Error: Could not retrieve Stream ARN from ARN/targetTable_Campi.json."
    exit 1
  fi
  
  echo "Creating Event Source Mapping for DynamoDB Streams using Stream ARN: $STREAM_ARN..."
  aws lambda create-event-source-mapping \
    --function-name alertTempHumLimit \
    --event-source-arn $STREAM_ARN \
    --batch-size 1 \
    --starting-position LATEST \
    --endpoint-url=http://localhost:4566

  if [ $? -eq 0 ]; then
    echo "Event Source Mapping created successfully."
  else
    echo "Error creating Event Source Mapping."
  fi
else
  echo "Error during Lambda function creation."
fi