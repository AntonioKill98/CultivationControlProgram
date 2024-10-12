#!/bin/bash


LAMBDA_FUNCTION_NAME="errorSendEMail"

# Deletation of Mapping
MAPPING_UUID=$(aws lambda list-event-source-mappings --function-name $LAMBDA_FUNCTION_NAME --query "EventSourceMappings[0].UUID" --output text --endpoint-url=http://localhost:4566)
if [ "$MAPPING_UUID" != "None" ]; then
  # Delete the Event Source Mapping if it exists
  echo "Deleting the Event Source Mapping with UUID $MAPPING_UUID..."
  aws lambda delete-event-source-mapping --uuid $MAPPING_UUID --endpoint-url=http://localhost:4566
  if [ $? -eq 0 ]; then
    echo "Event Source Mapping deleted successfully."
  else
    echo "Error deleting Event Source Mapping."
  fi
else
  echo "No Event Source Mapping found."
fi

# Delete of the Lambda function
echo "Deleting the Lambda function $LAMBDA_FUNCTION_NAME..."
aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME --endpoint-url=http://localhost:4566
if [ $? -eq 0 ]; then
    echo "Lambda function $LAMBDA_FUNCTION_NAME deleted successfully."
else
    echo "Error deleting the Lambda function $LAMBDA_FUNCTION_NAME."
fi