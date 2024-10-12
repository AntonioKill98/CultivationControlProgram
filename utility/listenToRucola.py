import paho.mqtt.client as mqtt
import boto3
import json
import datetime

temperature = None
humidity = None
sqs = boto3.resource('sqs', endpoint_url='http://localhost:4566')
queue = sqs.get_queue_by_name(QueueName="Rucola")
error_queue = sqs.get_queue_by_name(QueueName="Errors")

# MQTT Callback Function Message Receiving
def on_message(client, userdata, message):
    global temperature, humidity
    payload = json.loads(message.payload.decode("utf-8"))
    device_id = payload["device_id"]  # Ricevi il device_id

    if message.topic == "Rucola_Temp":
        temperature = payload["temperature"]
        print(f"Riceived temperature: {temperature} from device_id: {device_id}")
    elif message.topic == "Rucola_Hum":
        humidity = payload["humidity"]
        print(f"Riceived umidity: {humidity} from device_id: {device_id}")

    # Check ERR Message
    if temperature == "ERR" or humidity == "ERR":
        measure_date = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        for i in range(3):  # Send Error message for Rucola_0, Rucola_1, Rucola_2
            error_msg = '{"device_id": "Rucola_%s","error_date": "%s"}' % (i, measure_date)
            print(f"Send an Error Message to SQS: {error_msg}")
            error_queue.send_message(MessageBody=error_msg)
        temperature = None
        humidity = None
        return

    # When i have both the value (Temp e Hum) i can Write to the Queue
    if temperature is not None and humidity is not None:
        measure_date = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        for i in range(3):  # Simulation of 3 Device with only one
            msg_body = '{"device_id": "Rucola_%s","measure_date": "%s","cultivationName": "Rucola","temperature": "%s","humidity": "%s"}' \
                % (i, measure_date, temperature, humidity)
            print(f"Send a Message to SQS: {msg_body}")
            queue.send_message(MessageBody=msg_body)
        temperature = None
        humidity = None

client = mqtt.Client()

# MQTT Callback Function Connection
def on_connect(client, userdata, flags, rc):
    print("Connected to MQTT Broker with result: " + str(rc))
    # Sottoscrivi ai topic
    client.subscribe("Rucola_Temp")
    client.subscribe("Rucola_Hum")

# Conf of Callback Function
client.on_connect = on_connect
client.on_message = on_message

client.connect("localhost", 1883, 60)

client.loop_forever()