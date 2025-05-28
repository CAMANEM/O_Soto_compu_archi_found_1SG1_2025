#include <SoftwareSerial.h>

const int rxFPGA = 2;  
const int txFPGA = 3;

SoftwareSerial serialFPGA(rxFPGA, txFPGA);  // RX, TX

bool handshakeDone = false;
int lastCommandFromPC = 0;  // Último dato recibido del PC

unsigned long lastFPGAReceivedTime = 0;


void setup() {
  Serial.begin(9600);        // Comunicación con el PC (COM3)
  serialFPGA.begin(9600);    // Comunicación con la FPGA
  Serial.println("Handshake started");
}

void loop() {
  if (handshakeDone) {
    readFromFPGA();  // Lee datos de la FPGA
    sendSpeedToFPGA();  // Lee COM3 y Enviar el último comando al FPGA
    delay(500);  // Para evitar saturación

  } 
  else {
    performHandshake();
    delay(500);

  }
}

void performHandshake() {
  serialFPGA.write(15);  // Código de handshake

  if (serialFPGA.available()) {
    int response = serialFPGA.read();
    if (response == 14) {
      handshakeDone = true;
      lastFPGAReceivedTime = millis();
      Serial.println("Handshake complete.");
    }
  }
}

void sendSpeedToFPGA() {
  // 1. Leer desde el PC (COM3)
    if (Serial.available() > 0) {
      String input = Serial.readStringUntil('\n'); // Lee la línea completa como string
      // validar que input sea un numero de entre 0 y 15
      int value = input.toInt(); // Convierte "15" en número entero
      if (0 <= value && value <= 15) {
        lastCommandFromPC = value;
      }
    } 
    // 2. Enviar al FPGA el último comando
    serialFPGA.write(lastCommandFromPC);
}


void readFromFPGA() {
  if (serialFPGA.available()) {
    int data = serialFPGA.read();
    Serial.print("Data from FPGA: ");
    Serial.println(data);
    if (data == lastCommandFromPC) {
      lastFPGAReceivedTime = millis();
    }
  }
  // Check for timeout (3 seconds = 3000 ms)
  if (millis() - lastFPGAReceivedTime > 3000) {
    handshakeDone = false;
    Serial.println("No message from FPGA in 3 seconds. Handshake reset.");
  }
}