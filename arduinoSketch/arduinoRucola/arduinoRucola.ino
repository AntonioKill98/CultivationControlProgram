#include <WiFiS3.h>
#include <PubSubClient.h>
#include <DHT.h>
#include "secret.h"  // Include the secrets file

// Define the device_id
#define DEVICE_ID "Rucola_0"

// Configure DHT
#define DHTPIN 2
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Wi-Fi connection function
void connectToWiFi() {
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid, pass);
    delay(5000);
  }
  Serial.println("Connected to Wi-Fi!");
}

// MQTT connection function
void connectToMQTT() {
  while (!client.connected()) {
    Serial.print("Connecting to MQTT broker...");
    if (client.connect("arduinoClient")) {
      Serial.println("Connected.");
    } else {
      Serial.print("Failed, rc=");
      Serial.print(client.state());
      delay(5000);
    }
  }
}

// Device Setup
void setup() {
  Serial.begin(9600);
  dht.begin();
  connectToWiFi();
  
  client.setServer(server, 1883);
  connectToMQTT();
}

// Device Loop
void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }
  if (!client.connected()) {
    connectToMQTT();
  }
  client.loop();

  // Read temperature and humidity from the DHT22 sensor
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  // Check if there's an error or if the values are outside specified limits
  bool error = false;
  if (isnan(temperature) || isnan(humidity)) {
    error = true;
    Serial.println("Error reading from DHT sensor!");
  } else {
    if (temperature < 5 || temperature > 70) {
     error = true;
     Serial.println("Error, Temperature out of bounds!");
   }
    if (humidity < 10 || humidity > 95) {
     error = true;
     Serial.println("Error, Humidity out of bounds!");
    }
  }

  // If there's an error, send "ERR" for temperature and humidity
  if (error) {
    String tempPayload = "{\"device_id\": \"" + String(DEVICE_ID) + "\", \"temperature\": \"ERR\"}";
    client.publish("Rucola_Temp", tempPayload.c_str());
    Serial.print("Published: ");
    Serial.println(tempPayload);

    String humPayload = "{\"device_id\": \"" + String(DEVICE_ID) + "\", \"humidity\": \"ERR\"}";
    client.publish("Rucola_Hum", humPayload.c_str());
    Serial.print("Published: ");
    Serial.println(humPayload);
  } else {
    // If the values are valid, send the normal data
    String tempPayload = "{\"device_id\": \"" + String(DEVICE_ID) + "\", \"temperature\": \"" + String(temperature) + "\"}";
    client.publish("Rucola_Temp", tempPayload.c_str());
    Serial.print("Published: ");
    Serial.println(tempPayload);

    String humPayload = "{\"device_id\": \"" + String(DEVICE_ID) + "\", \"humidity\": \"" + String(humidity) + "\"}";
    client.publish("Rucola_Hum", humPayload.c_str());
    Serial.print("Published: ");
    Serial.println(humPayload);
  }

  delay(15000);  // Publish every 15 seconds
}