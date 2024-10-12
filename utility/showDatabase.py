import subprocess
import json
from tabulate import tabulate

def scan_dynamodb_table():
    # Execute AWS command to retrieve data from the "Campi" table
    command = ['aws', 'dynamodb', 'scan', '--table-name', 'Campi', '--endpoint-url', 'http://localhost:4566']
    result = subprocess.run(command, capture_output=True, text=True)

    if result.returncode != 0:
        print("Error executing AWS command:", result.stderr)
        return

    data = json.loads(result.stdout)
    items = data.get('Items', [])
    table_data = []
    headers = set()

    # Collect the keys (columns) and format the rows
    for item in items:
        row = {}
        for key, value in item.items():
            headers.add(key)
            # Extract the actual value from the DynamoDB dictionary
            value_type, value_content = next(iter(value.items()))
            row[key] = value_content
        table_data.append(row)

    # Force the order of headers with 'humidity' as the last field
    headers = ['cultivationName', 'device_ids', 'measure_date', 'temperature', 'humidity']
    
    # Create a list of rows with ordered values
    table_rows = [[row.get(h, '') for h in headers] for row in table_data]

    # Print the table with the customized header order
    print(tabulate(table_rows, headers=headers, tablefmt="pretty"))

if __name__ == "__main__":
    scan_dynamodb_table()