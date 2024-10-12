#!/bin/bash

# Array of devices
fields=("Rucola_0" "Rucola_1" "Rucola_2" "Insalata_0" "Insalata_1" "Insalata_2" "Basilico_0" "Basilico_1" "Basilico_2" "Radicchio_0" "Radicchio_1" "Radicchio_2")

# Pick a random device
random_device=${fields[$RANDOM % ${#fields[@]}]}
error_date=$(date +"%Y-%m-%d %H:%M:%S")
aws sqs send-message \
    --queue-url http://localhost:4566/000000000000/Errors \
    --message-body "{\"device_id\": \"$random_device\", \"error_date\": \"$error_date\"}" \
    --endpoint-url=http://localhost:4566
    
echo "Sent error message for device $random_device with error date $error_date"