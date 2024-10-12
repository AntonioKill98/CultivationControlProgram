#!/bin/bash

# Check if Queue name is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Queue name is required as an argument."
  echo "Usage: ./utility/printQueue.sh <QueueName>"
  exit 1
fi

# Queue name passed as an argument
QUEUE_NAME=$1

# Retrieve messages from the specified queue
aws sqs receive-message --queue-url http://localhost:4566/000000000000/$QUEUE_NAME --endpoint-url=http://localhost:4566 --max-number-of-messages 10

# Notify if there are no messages in the queue
if [ $? -ne 0 ]; then
  echo "Error: Could not read messages from the queue $QUEUE_NAME"
else
  echo "Contents of queue $QUEUE_NAME displayed."
fi