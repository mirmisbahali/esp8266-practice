#include<ESP8266WiFi.h>

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  WiFi.mode(WIFI_STA);
  WiFi.begin("esp8266", "123456789");
  Serial.print("Connecting to Wifi");
  while(WiFi.status()!= WL_CONNECTED)
  {
    Serial.print(".");
    delay(200);
  }
  Serial.println();
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.print("Mac Address: ");
  Serial.println(WiFi.macAddress()); 
}

void loop() {
  // put your main code here, to run repeatedly:

}
