import boto3
import json
import requests
import os

# Load the secrets from the JSON file
def load_secrets():
    with open('secrets.json', 'r') as file:
        return json.load(file)

# This function sends the Telegram message using the secrets loaded from the JSON file
def send_telegram_message(cultivation_name, device_ids, temperature, humidity, measure_date, secrets):
    token = secrets['telegram_alert']['bot_token']
    chat_id = secrets['telegram_alert']['chat_id']
    
    message = (f"🚨🚨 IMPORTANT WARNING 🚨🚨\n"
               f"Cultivation: {cultivation_name}\n"
               f"At: {measure_date}\n"
               f"Sensors: {device_ids}\n"
               f"Recorded:\n"
               f"Temperature: {temperature}°C\n"
               f"Humidity: {humidity}%\n"
               f"These values are beyond the safety limits for the crop.\n"
               f"🚨🚨 IMMEDIATE ACTION REQUIRED 🚨🚨")

    url = f"https://api.telegram.org/bot{token}/sendMessage"
    data = {"chat_id": chat_id, "text": message}
    response = requests.post(url, data=data)
    return response.status_code

# Handler of the Lambda Function
def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:4566')
    table = dynamodb.Table('Campi')

    # Load secrets from the secrets.json file
    secrets = load_secrets()

    limits = {
        'Rucola': {'temp_min': 10, 'temp_max': 30, 'hum_min': 10, 'hum_max': 80},
        'Insalata': {'temp_min': 5, 'temp_max': 25, 'hum_min': 5, 'hum_max': 70},
        'Basilico': {'temp_min': 10, 'temp_max': 30, 'hum_min': 10, 'hum_max': 80},
        'Radicchio': {'temp_min': 5, 'temp_max': 25, 'hum_min': 5, 'hum_max': 70}
    }

    for record in event['Records']:
        if record['eventName'] == 'INSERT' or record['eventName'] == 'MODIFY':
            new_image = record['dynamodb']['NewImage']
            cultivation_name = new_image['cultivationName']['S']
            temperature = float(new_image['temperature']['S'])
            humidity = float(new_image['humidity']['S'])
            device_ids = new_image['device_ids']['S']
            measure_date = new_image['measure_date']['S']  # Extract the measure date

            if (temperature < limits[cultivation_name]['temp_min'] or temperature > limits[cultivation_name]['temp_max'] or
                humidity < limits[cultivation_name]['hum_min'] or humidity > limits[cultivation_name]['hum_max']):
                
                print(f"Record for {cultivation_name} is outside the safety limits. "
                      f"Temperature: {temperature}, Humidity: {humidity}, Measure Date: {measure_date}")
                
                send_telegram_message(cultivation_name, device_ids, temperature, humidity, measure_date, secrets)
            else:
                print(f"Record for {cultivation_name} is within the safety limits.")

    return {
        'statusCode': 200,
        'body': json.dumps("Processed all records.")
    }