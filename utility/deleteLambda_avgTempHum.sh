#!/bin/bash

LAMBDA_FUNCTION_NAME="avgTempHum"
ENDPOINT_URL="http://localhost:4566"

# Deletation of the Lambda Function
echo "Eliminazione della Lambda function $LAMBDA_FUNCTION_NAME..."
aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME --endpoint-url=$ENDPOINT_URL

if [ $? -eq 0 ]; then
    echo "Lambda function $LAMBDA_FUNCTION_NAME eliminata con successo."
else
    echo "Errore durante l'eliminazione della Lambda function $LAMBDA_FUNCTION_NAME."
fi
