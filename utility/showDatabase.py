import boto3
import json
from tabulate import tabulate

def scan_dynamodb_table():
    # Crea un client DynamoDB puntando a LocalStack
    dynamodb = boto3.client('dynamodb', endpoint_url='http://localhost:4566')

    # Scansiona la tabella DynamoDB "Campi"
    response = dynamodb.scan(TableName='Campi')

    items = response.get('Items', [])
    table_data = []
    headers = set()

    # Colleziona le chiavi (le colonne) e formatta le righe
    for item in items:
        row = {}
        for key, value in item.items():
            headers.add(key)
            # Estrai il valore effettivo dal dizionario DynamoDB
            value_type, value_content = next(iter(value.items()))
            row[key] = value_content
        table_data.append(row)

    # Forza l'ordine delle intestazioni con 'humidity' come ultimo campo
    headers = ['cultivationName', 'device_ids', 'measure_date', 'temperature', 'humidity']

    # Crea una lista di righe con i valori ordinati
    table_rows = [[row.get(h, '') for h in headers] for row in table_data]

    # Stampa la tabella con le intestazioni ordinate
    print(tabulate(table_rows, headers=headers, tablefmt="pretty"))

if __name__ == "__main__":
    scan_dynamodb_table()
