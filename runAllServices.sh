#!/bin/bash

# Check if LocalStack is running
if ! nc -z localhost 4566; then
  echo "LocalStack is not running."
  echo "Please start LocalStack in another terminal by running ./utility/startLocalStack.sh"
  exit 1
fi

# Execute Python scripts to create the table and load test data
echo "Creating the Database Table..."
python3 settings/createTable.py

echo "Loading test data into the Table..."
python3 settings/loadData.py

# Create SQS queues
echo "Creating the Queues..."
bash utility/createQueues.sh

# Create the IAM role for Lambda
echo "Creating Lambda Role..."
bash utility/createLambdaRole.sh

# Create the Lambda function avgTempHum
echo "Creating Lambda Function avgTempHum..."
bash utility/createLambda_avgTempHum.sh

# Create the Lambda function errorSendEMail
echo "Creating Lambda Function errorSendEMail..."
bash utility/createLambda_errorSendEmail.sh

# Create the Lambda function alertTempHumLimit
echo "Creating Lambda Function alertTempHumLimit..."
bash utility/createLambda_alertTempHumLimit.sh

# Simulate IoT devices data collection
echo "Simulating IoT devices data collection..."
python3 utility/IoTDev_Emulation.py

# Display the initial state of the database
echo "Displaying the database before invoking the Lambda Function avgTempHum..."
python3 utility/showDatabase.py

# Just a Sleep so on slower systems Lambda can be Ready
echo "Now a little 7 seconds sleep so the system can be ready..."
sleep 7

# Manually invoke the Lambda function avgTempHum
echo "Manually invoking the Lambda Function avgTempHum..."
bash utility/invokeLambda_avgTempHum.sh

# Display the final state of the database
echo "Displaying the database after invoking the Lambda Function avgTempHum..."
python3 utility/showDatabase.py

# Test the Event Driven Lambda Function errorSendEMail
echo "Manually triggering the Lambda Function errorSendEMail..."
bash utility/test_errorSendEMail.sh

# Test the Event Driven Lambda Function alertTempHumLimit
echo "Manually triggering the Lambda Function alertTempHumLimit..."
python3 utility/test_alertTempHumLimit.py
