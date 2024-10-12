import boto3
import datetime


dynamodb = boto3.resource('dynamodb', endpoint_url='http://localhost:4566')
table = dynamodb.Table('Campi')

def update_insalata_record():
    new_temperature = 40.0  # Temperature > 25 (Insalata Limit)
    new_humidity = 90.0      # Umidity > 70 (Insalata Limit)

    measure_date = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    response = table.update_item(
        Key={
            'cultivationName': 'Insalata'
        },
        UpdateExpression='SET temperature = :temp, humidity = :hum, measure_date = :mdate',
        ExpressionAttributeValues={
            ':temp': str(new_temperature),
            ':hum': str(new_humidity),
            ':mdate': str(measure_date)
        },
        ReturnValues='UPDATED_NEW'
    )

    print("Record updated:", response['Attributes'])

if __name__ == '__main__':
    update_insalata_record()
