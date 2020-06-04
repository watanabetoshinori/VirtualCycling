/**
 * @file IndoorBike.ino
 * @brief VirtualCycling エアロバイク側モジュール
 * @author Watanabe Toshinori
 * @date 2020/05/30
 */

#include <M5Stack.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// オーディオジャックと接続したPIN
const int PIN = 5;

// BLE設定
const char *localName = "VirtualCycling";
const char *serviceUUID = "edeccb55-86b6-4ef2-8711-9cb7c0d3f6a0";
const char *characteristicUUID = "b44924cc-83d8-4376-81f5-6b80e5654768";

// 通知用のBLEキャラクタリスティック
BLECharacteristic *characteristic;

// BLEの端末接続状態
bool isDeviceConnected = false;

// 回転数
int count = 0;

// 現在の表示値
char countValue[6];

/**
 * M5Stackのセットアップ
 */
void setup(){
  M5.begin();

  // PINをプルアップに設定
  pinMode(PIN, INPUT_PULLUP);

  // BLEの初期化
  initializeBLE();

  M5.Lcd.setTextColor(WHITE);

  // 回転数
  M5.Lcd.drawString("00000", 80, 90, 7);

}

/**
 * M5Stackのループ
 */
void loop() {
  M5.update();

  int value = digitalRead(PIN);
  if (value == LOW) {
    // エアロバイクを回転すると通電する

    count += 1;
    updateCount();

    if (isDeviceConnected) {
      notify();
    }

    delay(200);
  }

}

/**
 * BLEのコールバック
 */
class ServerCallbacks: public BLEServerCallbacks {

    void onConnect(BLEServer* pServer) {
      isDeviceConnected = true;
    }

    void onDisconnect(BLEServer* pServer) {
      isDeviceConnected = false;

      // 一定時間待ってからアドバタイジングを再開
      delay(500);
      pServer->startAdvertising();
    }

};

/**
 * BLEを初期化します
 */
void initializeBLE() {
  // デバイスを作成
  BLEDevice::init(localName);

  // サーバーを作成
  BLEServer* server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  // サービスを作成
  BLEService* service = server->createService(serviceUUID);

  // 通知用のキャラクタリスティックを作成
  characteristic = service->createCharacteristic(
                          characteristicUUID,
                          BLECharacteristic::PROPERTY_NOTIFY
                        );
  
  characteristic->addDescriptor(new BLE2902());

  // サービスを開始
  service->start();

  // アドバタイジングを開始
  server->getAdvertising()->start();
}

/**
 * 距離の表示を更新します
 */
void updateCount() {
  char buffer[6];
  sprintf(buffer, "%05d", count);

  if (strcmp(countValue, buffer) != 0) {
    strncpy(countValue, buffer, 6);
    M5.Lcd.fillRoundRect(80, 90, 160, 110, 10, BLACK);
    M5.Lcd.drawString(countValue, 80, 90, 7);
  }
}

/**
 * BLEで回転を送信します
 */
void notify() {
  char json[24];
  sprintf(json, "{\"delta\": %lu}", millis());
  characteristic->setValue(json);
  characteristic->notify();

  Serial.println(json);
}
