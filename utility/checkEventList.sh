#!/bin/bash

# List all CloudWatch rules using LocalStack's endpoint
echo "Listing all CloudWatch rules..."
aws events list-rules --endpoint-url=http://localhost:4566

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "CloudWatch rules listed successfully."
else
    echo "Failed to list CloudWatch rules."
fi
