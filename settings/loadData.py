import boto3
import datetime
import random

# Configure DynamoDB on LocalStack
dynamodb = boto3.resource('dynamodb', endpoint_url="http://localhost:4566")

# Specify the DynamoDB table
table = dynamodb.Table('Campi')

# Define the agricultural fields and the number of devices per field
fields = [('Rucola', 3), ('Insalata', 3), ('Basilico', 3), ('Radicchio', 3)]

device_ids = []

# Generate device IDs for each field
for field, num_devices in fields:
    field_devices = ""
    for i in range(num_devices):
        field_devices += ("%s_%s") % (field, str(i)) + " "
    device_ids.append(field_devices)

# Populate DynamoDB with data for each field
for i in range(len(fields)):
    measure_date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    temperature = round(random.uniform(10.0, 30.0), 2)
    humidity = round(random.uniform(30.0, 70.0), 2)
    item = {
        'cultivationName': fields[i][0],
        'measure_date': measure_date,
        'temperature': str(temperature),
        'humidity': str(humidity),
        'device_ids': device_ids[i].strip()
    }
    table.put_item(Item=item)

    print("Stored item:", item)