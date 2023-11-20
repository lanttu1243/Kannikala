/*
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleServer.cpp
    Ported to Arduino ESP32 by Evandro Copercini
    updates by chegewara
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEServer *pServer = NULL;
BLEService *pService;
BLECharacteristic *pCharacteristic;
BLEAdvertising *pAdvertising;
BLECharacteristic *pContainer;
bool deviceConnected = false;
bool oldDeviceConnected = false;
uint8_t count = 0;

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* pCharacteristic) {
    for (int i = 0; i < 10; i++){
      digitalWrite(16, HIGH);
      delay(500);
      digitalWrite(16, LOW);
      delay(500);
    }
  };
};

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect (BLEServer *pServer) { deviceConnected = true; };
  void onDisconnect (BLEServer *pServer) { deviceConnected = false; }
};

void setup() {
  pinMode(14, OUTPUT);
  pinMode(15, OUTPUT);
  pinMode(16, OUTPUT);
  Serial.begin(115200);
  Serial.println("Starting BLE work!");
  digitalWrite(14, LOW);
  digitalWrite(15, LOW);
  digitalWrite(16, HIGH);

  BLEDevice::init("kannikala_v0.1");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks (new MyServerCallbacks());
  pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_NOTIFY
                                       );
  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->setValue("Hello World says Neil");
  pService->start();
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  pServer->getAdvertising()->start();
  Serial.println("Characteristic defined! Now you can read it in your phone!");
}

void loop() {
 
   if (deviceConnected) {
    Serial.println("Device Connected");
    digitalWrite(15, LOW);
    digitalWrite(14, HIGH);
    Serial.printf("Sending Value: %d\n", count);
    pCharacteristic->setValue(&count, 1);
    pCharacteristic->notify();
    delay (1000);  // bluetooth stack will go into congestion, if too many packets are sent
    digitalWrite(14, LOW);
    delay(1000);
    count++;
  }

  // disconnecting
  if (!deviceConnected && oldDeviceConnected) {
    Serial.println("Disconnected");
    digitalWrite(14, LOW);
    digitalWrite(15, HIGH);
    delay (500);  // give the bluetooth stack the chance to get things ready
    pServer->startAdvertising();  // restart advertising
    Serial.println ("Start advertising...");
    oldDeviceConnected = deviceConnected;
  }
  // connecting
  if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
    oldDeviceConnected = deviceConnected;
  }
}