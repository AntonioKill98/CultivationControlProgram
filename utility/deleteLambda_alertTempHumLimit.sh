#!/bin/bash

# Deletation of the Mapping
MAPPING_UUID=$(aws lambda list-event-source-mappings --function-name alertTempHumLimit --query "EventSourceMappings[0].UUID" --output text --endpoint-url=http://localhost:4566)
if [ "$MAPPING_UUID" != "None" ]; then
  # Cancella il mapping se esiste
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

# Deletation of the Lambda function alertTempHumLimit
echo "Deleting the Lambda function alertTempHumLimit..."
aws lambda delete-function --function-name alertTempHumLimit --endpoint-url=http://localhost:4566

if [ $? -eq 0 ]; then
  echo "Lambda function alertTempHumLimit deleted successfully."
else
  echo "Error deleting Lambda function."
fi