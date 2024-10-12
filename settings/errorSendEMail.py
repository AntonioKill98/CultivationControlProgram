import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import json

# Load secrets from the JSON file
def load_secrets():
    with open('secrets.json', 'r') as file:
        return json.load(file)

# This Function sends the email using the "smtplib", "MIMEMultipart" and "MIMEText" Libraries
def send_email(device_id, error_date, secrets):
    username = secrets['email_alert']['gmail_address']
    password = secrets['email_alert']['gmail_password']
    to_email = secrets['email_alert']['recipient_email']

    # Email details
    subject = "[Cultivation Control Program] Device Error Notification"
    body = f"A device encountered an error.\nDevice ID: {device_id}\nError Date: {error_date}"

    # Set up the email server (Gmail)
    server = smtplib.SMTP('smtp.gmail.com', 587)
    server.starttls()
    server.login(username, password)

    # Create the email
    msg = MIMEMultipart()
    msg['From'] = username
    msg['To'] = to_email
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    server.send_message(msg)
    server.quit()

# Handler of the Lambda Function
def lambda_handler(event, context):
    # Load secrets from the secrets.json file
    secrets = load_secrets()

    for record in event['Records']:
        payload = record['body']
        payload = json.loads(payload)
        device_id = payload['device_id']
        error_date = payload['error_date']
        send_email(device_id, error_date, secrets)