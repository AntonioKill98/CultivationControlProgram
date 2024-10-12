# Cultivation Control Program (CCP)

## Overview

The **Cultivation Control Program (CCP)** is a smart agricultural monitoring system designed to collect and analyze environmental data (temperature, humidity) from multiple IoT devices in different fields. It leverages AWS services like Lambda, DynamoDB, SQS, and SNS for a serverless architecture, enabling real-time notifications via email and Telegram.

This project was developed for the Serverless Computing exam at the University of Salerno, 2023/2024 academic year.

## Features

- **Environmental Monitoring**: Collects data from sensors (IoT devices) to monitor temperature and humidity levels.
- **Alerts**: Sends alerts when values go beyond specified thresholds via email and Telegram.
- **Data Storage**: Stores real-time sensor data in a DynamoDB table.
- **Event-Driven Architecture**: Uses AWS Lambda and SQS to process and analyze data.
  
## Technologies Used

- **Python**
- **AWS Lambda**
- **AWS DynamoDB**
- **AWS SQS**
- **AWS SNS**
- **LocalStack** (for local AWS emulation)
- **Arduino** (for IoT device simulation)