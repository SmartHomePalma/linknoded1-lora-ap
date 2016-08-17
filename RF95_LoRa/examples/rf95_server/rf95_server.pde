#include <LinkSpriteIO.h>
#include <string.h>
// rf95_server.pde
// -*- mode: C++ -*-
// Example sketch showing how to create a simple messageing server
// with the RH_RF95 class. RH_RF95 class does not provide for addressing or
// reliability, so you should only use RH_RF95  if you do not need the higher
// level messaging abilities.
// It is designed to work with the other example rf95_client
// Tested with Anarduino MiniWirelessLoRa, Rocket Scream Mini Ultra Pro with
// the RFM95W, Adafruit Feather M0 with RFM95

#include <SPI.h>
#include <RH_RF95.h>
#include <LinkSpriteIO.h>
// Singleton instance of the radio driver
//RH_RF95 rf95;           //Arduino UNO
RH_RF95 rf95(15, 5); // For LinkNode D1

// Need this on Arduino Zero with SerialUSB port (eg RocketScream Mini Ultra Pro)
//#define Serial SerialUSB

String deviceID = "xxxxxxxxxx";
String apikey = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";

LinkSpriteIO linksprite(deviceID,apikey);

void setup() 
{
  // Rocket Scream Mini Ultra Pro with the RFM95W only:
  // Ensure serial flash is not interfering with radio communication on SPI bus 
  Serial.begin(115200);
  linksprite.begin();
  while (!Serial) ; // Wait for serial port to be available
  if (!rf95.init())
    Serial.println("init failed");  
  // Defaults after init are 434.0MHz, 13dBm, Bw = 125 kHz, Cr = 4/5, Sf = 128chips/symbol, CRC on

  // The default transmitter power is 13dBm, using PA_BOOST.
  // If you are using RFM95/96/97/98 modules which uses the PA_BOOST transmitter pin, then 
  // you can set transmitter powers from 5 to 23 dBm:
//  driver.setTxPower(23, false);
  // If you are using Modtronix inAir4 or inAir9,or any other module which uses the
  // transmitter RFO pins and not the PA_BOOST pins
  // then you can configure the power transmitter power for -1 to 14 dBm and with useRFO true. 
  // Failure to do that will result in extremely low transmit powers.
//  driver.setTxPower(14, true);
}

void loop()
{
  String val,rssi;
  int i = 0;
  char tmp[10];
  char dat[RH_RF95_MAX_MESSAGE_LEN];
  if (rf95.available())
  {
    // Should be a message for us now   
    uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);
    if (rf95.recv(buf, &len))
    {
      RH_RF95::printBuffer("request: ", buf, len);
      sprintf(dat,"%s",buf);
      int v = strlen(dat);
      for(i=0;i<v;i++)
      {
        val += dat[i];
      }
      Serial.print("got request: ");
      Serial.println((char*)buf);
      Serial.print("RSSI: ");
      int a = rf95.lastRssi();
      Serial.println(rf95.lastRssi(), DEC);
      sprintf(tmp,"%d",a);
      int c = strlen(tmp);
      for(i=0;i<c;i++)
      {
          rssi += tmp[i];  
      }
      linksprite.update("data",val);
      linksprite.update("RSSI",rssi);
      // Send a reply
      uint8_t data[] = "And hello back to you";
      rf95.send(data, sizeof(data));
      rf95.waitPacketSent();
      Serial.println("Sent a reply");
    }
    else
    {
      Serial.println("recv failed");
    }
  }
}

