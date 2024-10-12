#!/bin/bash

QUEUES=("Rucola" "Insalata" "Basilico" "Radicchio" "Errors")
ENDPOINT_URL="http://localhost:4566"

for queue in "${QUEUES[@]}"; do
  echo "Emptying the Queue $queue..."
  QUEUE_URL=$(aws sqs get-queue-url --queue-name $queue --endpoint-url=$ENDPOINT_URL --query 'QueueUrl' --output text)
  
  if [ -z "$QUEUE_URL" ]; then
    echo "Queue $queue not Found."
    continue
  fi
  
  aws sqs purge-queue --queue-url $QUEUE_URL --endpoint-url=$ENDPOINT_URL
  
  if [ $? -eq 0 ]; then
    echo "Queue $queue is now Empty!."
  else
    echo "Error during the emptying of the queue $queue."
  fi
done

echo "Operazione completata."
