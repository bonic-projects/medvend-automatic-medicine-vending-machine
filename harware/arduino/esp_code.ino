#include <ESP32Servo.h>
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// Motor control pins
int in1 = 26;  // Motor 1
int in2 = 25;  // Motor 1
int in3 = 33;  // Motor 2
int in4 = 32;  // Motor 2
int in5 = 5;   // Motor 3
int in6 = 18;  // Motor 3

// Servo control pins
int servoPin1 = 13;  // Servo 1
int servoPin2 = 12;  // Servo 2
int servoPin3 = 14;  // Servo 3

Servo servo1;  // Create Servo object for Servo 1
Servo servo2;  // Create Servo object for Servo 2
Servo servo3;  // Create Servo object for Servo 3

// Wi-Fi and Firebase configuration
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
#define API_KEY "AIzaSyA4OH86Xq0FH2szZ8qnQRNr2OHP7x1MLDI"
#define DATABASE_URL "https://medvent-4b331-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define USER_EMAIL "device@gmail.com"
#define USER_PASSWORD "12345678"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
String uid;
FirebaseData stream;

void streamCallback(StreamData data) {
  Serial.println("NEW DATA!");
  String p = data.dataPath();
  Serial.println(p);
  printResult(data);

  FirebaseJson jVal = data.jsonObject();
  FirebaseJsonData med1;
  FirebaseJsonData med2;
  FirebaseJsonData med3;

  jVal.get(med1, "med1");
  jVal.get(med2, "med2");
  jVal.get(med3, "med3");

  if (med1.success) {
    Serial.println("Success data med1");
    bool value = med1.to<bool>();
    if (value)
      dispenseMed1();
  }
  
  if (med2.success) {
    Serial.println("Success data med2");
    bool value = med2.to<bool>();
    if (value)
      dispenseMed2();
  }
  
  if (med3.success) {
    Serial.println("Success data med3");
    bool value = med3.to<bool>();
    if (value)
      dispenseMed3();
  }
}

void streamTimeoutCallback(bool timeout) {
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
}

void setup() {
  // Set motor control pins as outputs
  pinMode(in1, OUTPUT);
  pinMode(in2, OUTPUT);
  pinMode(in3, OUTPUT);
  pinMode(in4, OUTPUT);
  pinMode(in5, OUTPUT);
  pinMode(in6, OUTPUT);

  // Attach servos to corresponding pins
  servo1.attach(servoPin1);
  servo2.attach(servoPin2);
  servo3.attach(servoPin3);

  // Initialize serial communication
  Serial.begin(115200);

  // Connect to Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Firebase setup
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;

  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Firebase.setDoubleDigits(5);
  config.timeout.serverResponse = 10 * 1000;

  // Getting the user UID
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  // Stream setup
  if (!Firebase.beginStream(stream, "devices/" + uid + "/data"))
    Serial.printf("stream begin error, %s\n\n", stream.errorReason().c_str());

  Firebase.setStreamCallback(stream, streamCallback, streamTimeoutCallback);
}

// Motor and Servo Control Functions
void motor1Clockwise() {
  digitalWrite(in1, LOW);
  digitalWrite(in2, HIGH);
  Serial.println("Motor 1 (in1, in2) rotating clockwise");
}

void motor1Stop() {
  digitalWrite(in1, LOW);
  digitalWrite(in2, LOW);
  Serial.println("Motor 1 (in1, in2) stopped");
}

void motor2Clockwise() {
  digitalWrite(in3, HIGH);
  digitalWrite(in4, LOW);
  Serial.println("Motor 2 (in3, in4) rotating clockwise");
}

void motor2Stop() {
  digitalWrite(in3, LOW);
  digitalWrite(in4, LOW);
  Serial.println("Motor 2 (in3, in4) stopped");
}

void motor3Clockwise() {
  digitalWrite(in5, HIGH);
  digitalWrite(in6, LOW);
  Serial.println("Motor 3 (in5, in6) rotating clockwise");
}

void motor3Stop() {
  digitalWrite(in5, LOW);
  digitalWrite(in6, LOW);
  Serial.println("Motor 3 (in5, in6) stopped");
}

void servo1Control() {
  servo1.write(90);
  delay(1000);
  servo1.write(0);
  Serial.println("Servo 1 moved from 0 to 90 degrees and back");
}

void servo2Control() {
  servo2.write(90);
  delay(1000);
  servo2.write(0);
  Serial.println("Servo 2 moved from 0 to 90 degrees and back");
}

void servo3Control() {
  servo3.write(90);
  delay(1000);
  servo3.write(0);
  Serial.println("Servo 3 moved from 0 to 90 degrees and back");
}

void dispenseMed1() {
  motor1Clockwise();
  delay(2000);
  motor1Stop();
  servo1Control();
}

void dispenseMed2() {
  motor2Clockwise();
  delay(2000);
  motor2Stop();
  servo2Control();
}

void dispenseMed3() {
  motor3Clockwise();
  delay(2000);
  motor3Stop();
  servo3Control();
}

void loop() {
  // Main loop
}
