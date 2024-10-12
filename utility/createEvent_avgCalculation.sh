#!/bin/bash

# Load the ARN of the Lambda function from the file
LAMBDA_ARN_FILE="ARN/targetLambda_avgTempHum.json"
if [ ! -f "$LAMBDA_ARN_FILE" ]; then
  echo "Error: The file $LAMBDA_ARN_FILE does not exist."
  exit 1
fi

# Extract Lambda ARN from the JSON file
LAMBDA_ARN=$(jq -r '.[0].Arn' "$LAMBDA_ARN_FILE")

# Check if the Lambda ARN is valid
if [ -z "$LAMBDA_ARN" ]; then
  echo "Error: Lambda ARN could not be retrieved."
  exit 1
fi

# Create a CloudWatch rule to trigger the Lambda every 60 minutes
echo "Creating a CloudWatch rule eventAvgCalculation..."
EVENT_ARN=$(aws events put-rule --name eventAvgCalculation \
  --schedule-expression 'rate(15 minutes)' \
  --query 'RuleArn' \
  --output text \
  --endpoint-url=http://localhost:4566)

# Check if the CloudWatch rule was created successfully
if [ $? -eq 0 ]; then
  echo "CloudWatch rule created successfully."

  # Save the event ARN to a file
  echo "Saving the event ARN to ARN/targetEvent_avgCalculation.json..."
  echo "[{\"Id\": \"1\", \"Arn\": \"$EVENT_ARN\"}]" > ARN/targetEvent_avgCalculation.json
  echo "Event ARN saved successfully."
else
  echo "Error creating the CloudWatch rule."
  exit 1
fi

# Add permission to allow the event to invoke the Lambda function
echo "Adding permission for eventAvgCalculation to invoke the Lambda function..."
aws lambda add-permission --function-name avgTempHum \
  --statement-id eventAvgCalculationPermission \
  --action 'lambda:InvokeFunction' \
  --principal events.amazonaws.com \
  --source-arn "$EVENT_ARN" \
  --endpoint-url=http://localhost:4566

if [ $? -eq 0 ]; then
  echo "Permission added successfully."
else
  echo "Error adding permission to the Lambda function."
  exit 1
fi

# Prepare the JSON file for targets (Lambda ARN)
TARGETS_FILE="ARN/targetLambda_avgTempHum.json"
if [ ! -f "$TARGETS_FILE" ]; then
  echo "Error: The file $TARGETS_FILE does not exist."
  exit 1
fi

# Add the Lambda function as the target of the CloudWatch rule
echo "Adding the Lambda function as a target to the eventAvgCalculation rule..."
aws events put-targets --rule eventAvgCalculation \
  --targets file://$TARGETS_FILE \
  --endpoint-url=http://localhost:4566

if [ $? -eq 0 ]; then
  echo "Lambda function successfully added as a target to the rule."
else
  echo "Error adding the Lambda function to the CloudWatch rule."
  exit 1
fi

echo "Setup complete. CloudWatch rule and Lambda function are now linked."
