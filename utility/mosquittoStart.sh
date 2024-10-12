#!/bin/bash

CONFIG_PATH="settings/mosquitto.conf"

# Control if the configuration file Exists
if [ -f "$CONFIG_PATH" ]; then
    echo "Mosquitto is starting with configuration: $CONFIG_PATH"
    mosquitto -c "$CONFIG_PATH"
else
    echo "Mosquitto Error: The configutation file $CONFIG_PATH doesn't exist."
    exit 1
fi
