import boto3
import datetime
import random

sqs = boto3.resource('sqs', endpoint_url='http://localhost:4566')
fields = [('Rucola', 3), ('Insalata', 3), ('Basilico', 3), ('Radicchio', 3)]

for field, device_id in fields:
    queue = sqs.get_queue_by_name(QueueName=field)
    measure_date = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    
    for i in range(device_id):
        if random.random() < 0.10:  # Simula errori con il 10% di probabilità
            error_queue = sqs.get_queue_by_name(QueueName="Errors")
            error_msg = '{"device_id": "%s_%s","error_date": "%s"}' % (field, str(i), measure_date)
            print(error_msg)
            error_queue.send_message(MessageBody=error_msg)
        else:
            temperature = round(random.uniform(10.0, 30.0), 2)
            humidity = round(random.uniform(30.0, 70.0), 2)
            msg_body = '{"device_id": "%s_%s","measure_date": "%s","cultivationName": "%s","temperature": "%s","humidity": "%s"}' \
                % (field, str(i), measure_date, field, str(temperature), str(humidity))
            print(msg_body)
            queue.send_message(MessageBody=msg_body)