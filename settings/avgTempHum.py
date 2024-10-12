import boto3
import datetime
import json
import platform

# Determine the appropriate endpoint based on the OS
#if platform.system() == 'Darwin':  # macOS
#    localstack_endpoint = 'http://host.docker.internal:4566'
#else:  # Linux, Windows, etc.
#    localstack_endpoint = 'http://localhost:4566'

localstack_endpoint = 'http://172.17.0.1:4566'

# Handler of the Lambda Function
def lambda_handler(event, context):
    try:
        print("Lambda function invoked successfully")
        sqs = boto3.resource('sqs', endpoint_url=localstack_endpoint)
        dynamodb = boto3.resource('dynamodb', endpoint_url=localstack_endpoint)
        table = dynamodb.Table('Campi')

        fields = ['Rucola', 'Insalata', 'Basilico', 'Radicchio']

        # Iterate over each cultivation
        for field in fields:
            print(f"Processing field: {field}")
            queue = sqs.get_queue_by_name(QueueName=field)
            messages = []
            while True:
                response = queue.receive_messages(MaxNumberOfMessages=10, VisibilityTimeout=10, WaitTimeSeconds=10)
                if response:
                    print(f"Found messages for {field}")
                    messages.extend(response)
                    device_ids = set()  # Use a set to avoid duplicates
                    total_temperature = 0
                    total_humidity = 0
                    count = 0
                    last_measured_data = datetime.datetime.combine(datetime.date.min, datetime.datetime.min.time())

                    for message in messages:
                        print(f"Processing message for {field}: {message.body}")
                        content = json.loads(message.body)
                        device_ids.add(content["device_id"])  # Add device_id to the set

                        measure_data = datetime.datetime.strptime(content["measure_date"], "%Y-%m-%d %H:%M:%S")
                        if measure_data > last_measured_data:
                            last_measured_data = measure_data

                        total_temperature += float(content["temperature"])
                        total_humidity += float(content["humidity"])
                        count += 1

                        message.delete()

                    avg_temperature = round(total_temperature / count, 2) if count > 0 else 0
                    avg_humidity = round(total_humidity / count, 2) if count > 0 else 0

                    # Prepare item for insertion into DynamoDB
                    item = {
                        'cultivationName': field,
                        'measure_date': str(last_measured_data),
                        'temperature': str(avg_temperature),
                        'humidity': str(avg_humidity),
                        'device_ids': " ".join(device_ids)
                    }
                    table.put_item(Item=item)  # Store the item in DynamoDB
                    print(f"Stored item for {field}: {item}")
                else:
                    print(f"No messages found for {field}")
                    break
            print(f"Finished processing field: {field}")

    except Exception as e:
        print(f"Error during Lambda execution: {str(e)}")