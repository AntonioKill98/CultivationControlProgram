#!/bin/bash

# Script to run LocalStack using Docker

echo "Starting LocalStack Docker container..."

docker run --rm -it -p 4566:4566 -p 4571:4571 -v /var/run/docker.sock:/var/run/docker.sock localstack/localstack

echo "LocalStack Docker container stopped."
