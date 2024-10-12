#!/bin/bash

aws sqs create-queue --queue-name Rucola --endpoint-url=http://localhost:4566
echo "Queue Rucola created!"

aws sqs create-queue --queue-name Insalata --endpoint-url=http://localhost:4566
echo "Queue Insalata created!"

aws sqs create-queue --queue-name Basilico --endpoint-url=http://localhost:4566
echo "Queue Basilico created!"

aws sqs create-queue --queue-name Radicchio --endpoint-url=http://localhost:4566
echo "Queue Radicchio created!"

aws sqs create-queue --queue-name Errors --endpoint-url=http://localhost:4566
echo "Queue Errors created!"

echo "List all active Queues:"
aws sqs list-queues --endpoint-url=http://localhost:4566
