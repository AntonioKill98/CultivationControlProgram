# Cultivation Control Program (CCP)

## Overview

The **Cultivation Control Program (CCP)** is a smart agricultural monitoring system designed to collect and analyze environmental data (temperature, humidity) from multiple IoT devices in different fields. It leverages AWS services like Lambda, DynamoDB, SQS, and SNS for a serverless architecture, enabling real-time notifications via EMail and Telegram.

This project was developed for the **Serverless Computing** exam at the **University of Salerno**, 2023/2024 academic year.

## Features

- **Environmental Monitoring**: Collects data from sensors to monitor Temperature and Humidity levels. These sensors can be emulated but also can be real.
- **Alerts**: Sends Alerts when values go beyond specified thresholds via Telegram, so an Employee can do something.
- **Alarm**: Send an Alarm EMail to a given Address (and from another given Address) when a sensor send an error Message. 
- **Data Storage**: Stores real-time sensor data in a DynamoDB table.
- **Event-Driven Architecture**: Uses AWS Lambda and SQS to process and analyze data.
  
## What do you need to run this Project

- **Python** (mine is the 3.10 so i can suggest this version);
- **Docker**;
- **LocalStack** (for local AWS emulation in a Docker Container);
- **Arduino** and **Arduino IDE**(If you want to use a real Sensors);
- **AWS CLI** (So we can control what is happening in the Container);
- **boto3** (Python Library for interact with the System);

## Architecture

We are in a field with four different greenhouse cultivations, each requiring specific humidity and temperature conditions. Three sensors are installed in each greenhouse to measure temperature and humidity every minute. These sensors communicate with an MQTT Broker, publishing to topics named **`"CultivationName_Temperature"`** and **`"CultivationName_Humidity"`**, sending messages with their ID and the recorded measurement. If an error occurs, the sensors send **`"ERR"`** in place of the value.

An application listens to these MQTT topics and inserts the collected data into specific SQS queues, formatting each entry as **`Device ID, Temperature, Humidity, Measure Date`**.

Here, the first Lambda function, **`avgTempHum`**, is triggered every 5 minutes. It calculates the average temperature and humidity for each cultivation based on the values in the queue, then stores the results in a DynamoDB database.

Another Lambda function, **`errorSendEMail`**, monitors the **`Error`** queue and, upon receiving data, sends an email alert. This function retrieves Gmail account credentials and recipient addresses from a **`secrets.json`** file.

Lastly, the **`alertTempHumLimit`** Lambda function is triggered whenever the database is updated. It checks whether the new average temperature and humidity values exceed predefined thresholds. If they do, an urgent notification is sent via Telegram using a bot. The bot token and chat ID are specified in **`secrets.json`**.

In this project, we can also emulate sensor behavior or directly load test data into the database to better test the Lambda functions, all through the scripts available in the **`utility`** folder of the project.

## Getting Started

### Easy Version (Recommended for Beginners)

1. Insert the necessary credentials into **`secrets.json`** to enable the **`errorSendEMail`** and **`alertTempHumLimit`** Lambda functions.

2. Start the LocalStack Docker container by running:
   `./utility/startLocalStack.sh`
   in one terminal.

3. In a new terminal, run:
   `./runAllServices.sh`
   This will activate, configure, and test all project components.

### Intermediate Version

1. Start the LocalStack Docker container with the command:
   `./utility/startLocalStack.sh`
   This command runs the following Docker command:
   `docker run --rm -it -p 4566:4566 -p 4571:4571 -v /var/run/docker.sock:/var/run/docker.sock localstack/localstack`

2. Create the DynamoDB table by running:
   `python3 settings/createTable.py`
   This script uses Boto3 to create a table with DynamoDB streams enabled, which will be used later.

3. Load initial data into the database by running:
   `python3 settings/loadData.py`
   This populates the database with random data entries.

4. Create the necessary SQS queues by running:
   `./utility/createQueques.sh`
   This script runs:
   `aws sqs create-queue --queue-name nameOfQueue --endpoint-url=http://localhost:4566`
   for each queue required.

5. Create the Lambda Role and assign a policy by running:
   `./utility/createLambdaRole.sh`
   This script creates a role using:
   `aws iam create-role ...`
   and assigns a policy using:
   `aws iam put-role-policy ...`

6. Create the first Lambda function, **avgTempHum**, by running:
   `./utility/createLambda_avgTempHum.sh`
   This script creates a ZIP file containing the **settings/avgTempHum.py** script and registers the Lambda function using:
   `aws lambda create-function ...`
   while associating the Lambda Role created earlier.

7. Test the first Lambda function manually:
   - Fill the queues with sensor data by running:
     `python3 utility/IoTDev_Emulation.py`
   - Check the queue contents with:
     `./utility/printQueue.sh nameOfQueue`
   - View the database contents before invocation:
     `python3 utility/showDatabase.py`
   - Manually invoke the Lambda function:
     `./utility/invokeLambda_avgTempHum.sh`
   - View the database again after invocation:
     `python3 utility/showDatabase.py`
   - Finally, set up a scheduled event to trigger the Lambda function every 15 minutes using:
     `./utility/createEvent_avgCalculation.sh`
     This creates a CloudWatch rule using:
     `aws events put-role ...`
     and associates the event with the Lambda function using:
     `aws lambda add-permission ...`

8. Initialize the second Lambda function, **errorSendEMail**, by running:
   `./utility/createLambda_errorSendEMail.sh`
   This script creates a ZIP file containing **settings/errorSendEMail.py** and **secrets.json**, creates the Lambda function with the previously created Lambda Role, and sets up event source mapping for the **Error** queue. 
   Test it using:
   `./utility/test_errorSendEMail.sh`
   which publishes a message to the **Error** queue simulating a sensor failure.

9. Lastly, initialize the **alertTempHumLimit** Lambda function using:
   `./utility/createLambda_alertTempHumLimit.sh`
   This script creates the necessary ZIP file containing **settings/alertTempHumLimit.py**, adds **secrets.json**, and includes the **requests** library (required for the Telegram bot) from **settings/alertTempHumLimit_package**. After creating the Lambda function, the script sets up event source mapping between DynamoDB updates (enabled by the stream) and the Lambda function. 
   Test this by running:
   `python3 ./utility/test_alertTempHumLimit.py`
   which inserts faulty data into the **Insalata** cultivation record to trigger the Lambda function.
