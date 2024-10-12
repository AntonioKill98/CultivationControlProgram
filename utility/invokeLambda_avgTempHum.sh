#!/bin/bash

LAMBDA_FUNCTION_NAME="avgTempHum"
ENDPOINT_URL="http://localhost:4566"

echo "Invokation of the Lambda Function $LAMBDA_FUNCTION_NAME..."
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME --payload '{}' out --endpoint-url=$ENDPOINT_URL
if [ $? -eq 0 ]; then
    echo "Lambda Function $LAMBDA_FUNCTION_NAME invoked with success."
else
    echo "Errore during the Invokation of the Lambda Function $LAMBDA_FUNCTION_NAME."
fi
