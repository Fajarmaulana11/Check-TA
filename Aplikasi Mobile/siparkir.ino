
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>      
#include <ESP32Servo.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SPI.h>
#include <MFRC522.h>
#include <HTTPClient.h>
#include <Preferences.h>



// ✅ Firebase
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"
// Firebase
#define API_KEY "AIzaSyCaLvOB31bMXPwFfIz5Gy5ecGZhDs6kW34"
#define DATABASE_URL "https://sistemparkir-cc7d8-default-rtdb.firebaseio.com/"
#define LEGACY_TOKEN "1uQ1lRWJqVoxeuGaSbJvzjEGX9MpRdaqXCFAxrP0"

// RFID Pins
#define SS_MASUK 19
#define RST_MASUK 23
#define SS_KELUAR 2
#define RST_KELUAR 15

// SPI Shared Bus
#define SCK  17
#define MISO 22
#define MOSI 21

// Servo
#define SERVO_MASUK_PIN 33
#define SERVO_KELUAR_PIN 25

// Buzzer
#define BUZZER_PIN 13

// IR Sensor
#define IR_MASUK_PIN 34
#define IR_KELUAR_PIN 35

// LED Status
#define LED_PIN 12

// Tombol Reset
#define RESET_BUTTON_PIN 14


const char* ssid = "Fajar";
const char* password = "fajar123";

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
String apiKey;
String databaseUrl;
const char* ntpServer = "time.nist.gov";
const long gmtOffset_sec = 7 * 3600;  // GMT+7
const int daylightOffset_sec = 0;


// RFID & Servo
MFRC522 rfidMasuk(SS_MASUK, RST_MASUK);
MFRC522 rfidKeluar(SS_KELUAR, RST_KELUAR);
Servo servoMasuk;
Servo servoKeluar;

// LCD
LiquidCrystal_I2C lcd(0x27, 16, 2);

// Variabel
int totalSlot = 10;
int jumlahMasuk = 0;
int jumlahKeluar = 0;
int slotTerpakai = 0;
unsigned long previousMillis = 0;
bool ledState = false;

unsigned long buttonPressStart = 0;
bool buttonPressed = false;
const unsigned long resetHoldTime = 10000; // 10 detik
bool emergencyActive = false;


void tampilkanDefaultLCD() {
  int slotKosong = 0;

  // Mengambil data slot kosong langsung dari Firebase
  if (Firebase.RTDB.getInt(&fbdo, "info_parkir/slot")) {
    slotKosong = fbdo.intData();  // Mengambil nilai slot kosong dari Firebase
  }

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(" SIPARKIR SLOT:");
  lcd.setCursor(0, 1);
  lcd.print("       " + String(slotKosong)); // Menampilkan jumlah slot kosong dari Firebase
}


void tampilkanPesanLCD(String pesan) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(pesan);
  delay(3000);
  tampilkanDefaultLCD();
}

void tampilkanPesanLCDDuaBaris(String baris1, String baris2) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(baris1);
  lcd.setCursor(0, 1);
  lcd.print(baris2);
  delay(3000);
  tampilkanDefaultLCD();
}

bool bukaPintu(Servo& servo, int irPin, bool isMasuk) {
  // Buka pintu
  if (isMasuk) {
    servo.write(90); // buka arah masuk
  } else {
    servo.write(90); // buka arah keluar (ubah dari 0 ke 90)
  }

  Serial.println("🚗 Pintu terbuka, menunggu kendaraan melewati sensor IR...");

  unsigned long waktuMulai = millis();
  const unsigned long batasWaktu = 10000; // timeout jika kendaraan tidak muncul
  bool terdeteksi = false;

  // Tunggu kendaraan muncul
  while (!terdeteksi && (millis() - waktuMulai < batasWaktu)) {
    if (digitalRead(irPin) == LOW) {
      terdeteksi = true;
      Serial.println("✅ Kendaraan terdeteksi IR...");
    }
    delay(100);
  }

  if (!terdeteksi) {
    Serial.println("⚠️ Tidak ada kendaraan yang muncul, timeout.");

    // Tutup pintu
    if (isMasuk) {
      servo.write(0);
    } else {
      servo.write(0); // tutup keluar (ubah dari 90 ke 0)
    }

    return false;
  }

  // Tunggu kendaraan lewat
  while (digitalRead(irPin) == LOW) {
    delay(100);
  }

  Serial.println("✅ Kendaraan sudah melewati sensor IR.");

  // Tutup pintu
  if (isMasuk) {
    servo.write(0);
  } else {
    servo.write(0); // ubah dari 90 ke 0
  }

  return true;
}






void updateFirebase() {
  int slotKosong = totalSlot - slotTerpakai;
  Firebase.RTDB.setInt(&fbdo, "info_parkir/masuk", jumlahMasuk);
  Firebase.RTDB.setInt(&fbdo, "info_parkir/keluar", jumlahKeluar);
  Firebase.RTDB.setInt(&fbdo, "info_parkir/slot", slotKosong);
}

void kirimDataKeServer(String uid, String activity) {
  HTTPClient http;
  http.begin("https://esp32-firebase-service.vercel.app/api/kirim-data");

  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("❌ Gagal mendapatkan waktu lokal");
    return;
  }

  char timeString[30];
  strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%S.000Z", &timeinfo);

  String payload = "{\"uid\":\"" + uid + "\",\"activity\":\"" + activity + "\",\"time\":\"" + String(timeString) + "\"}";
  Serial.println("📤 Kirim Payload: " + payload);

  http.begin("https://esp32-firebase-service.vercel.app/api/kirim-data");  // ✅ langsung tulis URL-nya
  http.addHeader("Content-Type", "application/json");

  int httpResponseCode = http.POST(payload);

  if (httpResponseCode > 0) {
    Serial.printf("✅ Kirim berhasil: %d\n", httpResponseCode);
    String response = http.getString();
    Serial.println("Response: " + response);
  } else {
    Serial.printf("❌ Kirim gagal: %s\n", http.errorToString(httpResponseCode).c_str());
  }

  http.end();
}


void loadDataFromFirebase() {
  if (Firebase.RTDB.getInt(&fbdo, "info_parkir/masuk")) {
    jumlahMasuk = fbdo.intData();
  }

  if (Firebase.RTDB.getInt(&fbdo, "info_parkir/keluar")) {
    jumlahKeluar = fbdo.intData();
  }

  int slotKosong = 10;
  if (Firebase.RTDB.getInt(&fbdo, "info_parkir/slot")) {
    slotKosong = fbdo.intData();
  }

  slotTerpakai = totalSlot - slotKosong;

  Serial.println("✅ Data berhasil dimuat dari Firebase");
}



String getUID(MFRC522& rfid) {
  String uid = "";
  for (byte i = 0; i < rfid.uid.size; i++) {
    uid += String(rfid.uid.uidByte[i], HEX);
  }
  uid.toUpperCase();
  return uid;
}

void bunyiBuzzerTerdaftar() {
  digitalWrite(BUZZER_PIN, HIGH);
  delay(100);
  digitalWrite(BUZZER_PIN, LOW);
}

void bunyiBuzzerTidakTerdaftar() {
  for (int i = 0; i < 5; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(100);
    digitalWrite(BUZZER_PIN, LOW);
    delay(400);
  }
}
void prosesKartu(MFRC522& rfid, bool isMasuk) {
  String rfidUID = getUID(rfid);
  Serial.println((isMasuk ? "Masuk" : "Keluar") + String(" UID: ") + rfidUID);
  String path = "daftar_kartu/" + rfidUID;

  if (Firebase.RTDB.getBool(&fbdo, path + "/value") && fbdo.boolData()) {
    if (Firebase.RTDB.getBool(&fbdo, path + "/status")) {
      bool status = fbdo.boolData();

      if (isMasuk) {
        if (!status) {  // Belum masuk
          if (slotTerpakai < totalSlot) {
            tampilkanPesanLCD("Silahkan Masuk");

            bool kendaraanLewat = bukaPintu(servoMasuk, IR_MASUK_PIN, true);
            if (kendaraanLewat) {
              jumlahMasuk++;          // ✅ hanya tambah kalau IR mendeteksi kendaraan
              slotTerpakai++;         // ✅
              Firebase.RTDB.setBool(&fbdo, path + "/status", true);
              updateFirebase();
              bunyiBuzzerTerdaftar();
              tampilkanDefaultLCD();
              kirimDataKeServer(rfidUID, "masuk");
            } else {
              tampilkanPesanLCD("Gagal Masuk!");
              bunyiBuzzerTidakTerdaftar();
            }
          } else {
            tampilkanPesanLCD("Parkiran Penuh!");
          }
        } else {
          tampilkanPesanLCD("Sudah Masuk!");
        }

      } else {  // Keluar
        if (status) {  // Sudah masuk
          tampilkanPesanLCD("Terima Kasih");

          bool kendaraanLewat = bukaPintu(servoKeluar, IR_KELUAR_PIN, false);
          if (kendaraanLewat) {
            jumlahKeluar++;       // ✅ hanya kurang kalau IR mendeteksi kendaraan
            slotTerpakai--;       // ✅
            Firebase.RTDB.setBool(&fbdo, path + "/status", false);
            updateFirebase();
            bunyiBuzzerTerdaftar();
            tampilkanDefaultLCD();
            kirimDataKeServer(rfidUID, "keluar");
          } else {
            tampilkanPesanLCD("Gagal Keluar!");
            bunyiBuzzerTidakTerdaftar();
          }
        } else {
          tampilkanPesanLCD("Belum Masuk!");
        }
      }

    } else {
      tampilkanPesanLCD("Status Tidak Ada");
      bunyiBuzzerTidakTerdaftar();
    }

  } else {
    tampilkanPesanLCDDuaBaris("Kartu Tidak", "Terdaftar");
    bunyiBuzzerTidakTerdaftar();
  }

  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();
}



void resetDataFirebase() {
  Serial.println("⚠️ Reset data Firebase...");

  Firebase.RTDB.setInt(&fbdo, "info_parkir/masuk", 0);
  Firebase.RTDB.setInt(&fbdo, "info_parkir/keluar", 0);
  Firebase.RTDB.setInt(&fbdo, "info_parkir/slot", totalSlot);

  jumlahMasuk = 0;
  jumlahKeluar = 0;
  slotTerpakai = 0;

  // Ambil isi JSON
  if (Firebase.RTDB.getJSON(&fbdo, "daftar_kartu")) {
    FirebaseJson json = fbdo.to<FirebaseJson>();  // Ambil JSON penuh

    String raw;
    json.toString(raw, true);
    Serial.println("📦 Data JSON:");
    Serial.println(raw);

    size_t len = json.iteratorBegin();
    Serial.printf("🔍 Total Key: %d\n", len);

    String uidKey, dummyVal;
    int type;

    for (size_t i = 0; i < len; i++) {
      json.iteratorGet(i, type, uidKey, dummyVal);

      if (uidKey.length() > 0) {
        String statusPath = "daftar_kartu/" + uidKey + "/status";
        bool success = Firebase.RTDB.setBool(&fbdo, statusPath, false);
        Serial.print("Set status false untuk UID ");
        Serial.print(uidKey);
        Serial.println(success ? " ✅ BERHASIL" : " ❌ GAGAL");
      } else {
        Serial.println("❌ UID kosong, dilewati");
      }

      delay(200);  // Hindari limit koneksi
    }

    json.iteratorEnd();
  } else {
    Serial.println("❌ Gagal ambil data daftar_kartu");
  }

  tampilkanPesanLCD("Data Direset");
}


void setup() {
  Serial.begin(115200);

  Wire.begin(27, 26);
  lcd.init();
  lcd.backlight();
  tampilkanDefaultLCD();
  

  servoMasuk.attach(SERVO_MASUK_PIN);
  servoKeluar.attach(SERVO_KELUAR_PIN);
  
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(IR_MASUK_PIN, INPUT_PULLUP);
  pinMode(IR_KELUAR_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  pinMode(RESET_BUTTON_PIN, INPUT_PULLUP);

  SPI.begin(SCK, MISO, MOSI, SS_MASUK);
  rfidMasuk.PCD_Init();
  rfidKeluar.PCD_Init();

  WiFi.mode(WIFI_STA);

  // Inisialisasi WiFi
  WiFi.begin(ssid, password);
  Serial.print("Menghubungkan ke WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ Terhubung ke WiFi");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);

  Serial.println("Menunggu waktu NTP...");

  struct tm timeinfo;
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWaktu NTP berhasil didapatkan:");
  Serial.println(&timeinfo, "%Y-%m-%d %H:%M:%S");


  // === Firebase config ===
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.signer.tokens.legacy_token = LEGACY_TOKEN;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);


  // Load data awal dari Firebase
  loadDataFromFirebase();

  tampilkanDefaultLCD();

  Serial.println("🚀 Setup selesai.");
}


void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= 500) {
      previousMillis = currentMillis;
      ledState = !ledState;
      digitalWrite(LED_PIN, ledState);
    }
    return;
  } else {
    digitalWrite(LED_PIN, HIGH);
  }

  int buttonState = digitalRead(RESET_BUTTON_PIN);

if (buttonState == LOW && !buttonPressed) {
  buttonPressed = true;
  buttonPressStart = millis();
  emergencyActive = true;

  // Bunyikan buzzer darurat
  digitalWrite(BUZZER_PIN, HIGH);
  Serial.println("🚨 Tombol emergency ditekan - buzzer aktif");
}

if (buttonState == LOW && buttonPressed) {
  if (millis() - buttonPressStart >= resetHoldTime) {
    Serial.println("♻️ Tombol ditekan lama - reset sistem");

    // Matikan buzzer
    digitalWrite(BUZZER_PIN, LOW);
    resetDataFirebase();
    // Lakukan reset (misal: reset data parkir, atau restart ESP

    tampilkanPesanLCDDuaBaris("Sistem di-reset", "oleh petugas");

    buttonPressed = false;
    emergencyActive = false;
  }
}

if (buttonState == HIGH && buttonPressed) {
  // Tombol dilepas sebelum 10 detik
  digitalWrite(BUZZER_PIN, LOW);
  buttonPressed = false;
  emergencyActive = false;
  Serial.println("🔕 Tombol emergency dilepas");
}


  if (rfidMasuk.PICC_IsNewCardPresent() && rfidMasuk.PICC_ReadCardSerial()) {
    prosesKartu(rfidMasuk, true);
  }

  if (rfidKeluar.PICC_IsNewCardPresent() && rfidKeluar.PICC_ReadCardSerial()) {
    prosesKartu(rfidKeluar, false);
  }
}
