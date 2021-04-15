#include <Arduino.h>
#include <ProtocolBuffer.hpp>
#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
#include <avr/power.h>
#endif

/// Some globals
const int RELAY_PIN = 4;
const int LED = 13;
const byte PROTOCOL_START_CHAR = 254;
const byte PROTOCOL_END_CHAR = 255;
const int PIN = 8;
const int NUMPIXELS = 124; // 45 + 17 + 45 + 17
const bool SEND_DEBUG = true;
const bool SEND_ERROR = true;
const bool SEND_VERBOSE = false;
const bool SEND_INDEX_ERROR = true;
const bool SEND_SUCCESS = false;

/// The neopixel instance
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

ProtocolBuffer<500, NUMPIXELS * 3, PROTOCOL_START_CHAR, PROTOCOL_END_CHAR> protocolBuffer;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// Initialize
void setup()
{
  pinMode(RELAY_PIN, INPUT_PULLUP);
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED, OUTPUT);
  pixels.begin();
  pixels.show();
  Serial.begin(230400);

  Serial.setTimeout(10);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// SET LEDS
void setLeds(byte imageData[], uint16_t count)
{
  // wrong amount?
  if (count != NUMPIXELS * 3)
  {
    if (SEND_ERROR)
    {
      Serial.print("wrong number of elements given (");
      Serial.print(count);
      Serial.println(")");
    }
    return;
  }
  // send data to LEDs
  if (pixels.canShow())
  {
    for (int index = 0; index < NUMPIXELS; index++)
    {
      int offset = index * 3;
      auto color = pixels.Color(imageData[offset + 0],
                                imageData[offset + 1],
                                imageData[offset + 2]);
      pixels.setPixelColor(index, color);
    }
    pixels.show();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// PRINT NUm
void printNum(const char *var, int num)
{
  if (!SEND_VERBOSE)
  {
    return;
  }
  char message[50];
  sprintf(message, var, num);
  Serial.println(message);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// PRINT ARRAy
void printArray(byte array[], uint16_t count)
{
  if (!SEND_VERBOSE)
  {
    return;
  }
  Serial.print("array(");
  Serial.print(count);
  Serial.print("): ");
  for (uint16_t index = 0; index < count; index++)
  {
    Serial.print(array[index]);
    Serial.print(" ");
  }
  Serial.println(" ");
  Serial.flush();
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// SERIAL PROCESSING
void processSerial()
{
  // check for overflow
  if (Serial.available() == SERIAL_RX_BUFFER_SIZE)
  {
    if (SEND_DEBUG)
    {
      Serial.println("overvlow");
    }
  }
  // read all data to ring buffer
  bool endSignal = false;
  while (Serial.available() > 0)
  {
    byte incoming = Serial.read();
    printNum("incoming: %i", incoming);
    endSignal = protocolBuffer.putByte(incoming);
  }
  // check if there is somethig to read
  if (!endSignal)
  {
    return;
  }
  // get the led buffer
  auto ledBuffer = protocolBuffer.getProtocolChunk().buffer;

  // set leds
  setLeds(ledBuffer, NUMPIXELS * 3);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 3BYTE
void process3ByteColor()
{
  // try to read full chunk from serial port
  bool imageReady = false;
  unsigned int maxReadCount = NUMPIXELS * 3 + 1; // each color 3 bytes plus protocol end char
  uint8_t imageData[maxReadCount] = {};
  if (Serial.available())
  {
    size_t readSize = Serial.readBytesUntil(PROTOCOL_END_CHAR, imageData, maxReadCount);
    if (readSize == maxReadCount)
    {
      imageReady = true;
    }
    else
    {
      char message[100];
      sprintf(message, "Error not enough bytes received: %i", readSize);
      Serial.println(message);
    }
  }

  // // verify
  // if (imageReady)
  // {
  //   // verify results
  //   for (int index = 0; index < 180; index++)
  //   {
  //     if (index != imageData[index])
  //     {
  //       char message[100];
  //       sprintf(message, "Error at index: %i - %i", index, imageData[index]);
  //       Serial.println(message);
  //     }
  //   }
  //   if (imageData[180] != 255)
  //   {
  //     char message[100];
  //     sprintf(message, "Error at last index: %i", imageData[180]);
  //     Serial.println(message);
  //   }
  //   Serial.println("Verification done");
  // }

  // send data to LEDs
  if (imageReady && pixels.canShow())
  {
    for (int index = 0; index < NUMPIXELS; index++)
    {
      int offset = index * 3;
      auto color = pixels.Color(imageData[offset + 0],
                                imageData[offset + 1],
                                imageData[offset + 2]);
      pixels.setPixelColor(index, color);
    }
    pixels.show();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 1BYTE
void processSingleByteColors()
{
  /// ONLY sIMPLE COLORS, 0red, 1green, 2blue
  bool imageReady = false;
  unsigned int maxReadCount = NUMPIXELS + 1;
  uint8_t imageData[maxReadCount] = {};
  if (Serial.available())
  {
    size_t readSize = Serial.readBytesUntil(PROTOCOL_END_CHAR, imageData, maxReadCount);
    if (readSize == maxReadCount)
    {
      imageReady = true;
    }
    else
    {
      char message[100];
      sprintf(message, "Error not enough bytes received: %i", readSize);
      Serial.println(message);
    }
  }

  // send data to LEDs
  if (imageReady && pixels.canShow())
  {
    for (int index = 0; index < NUMPIXELS; index++)
    {
      if (imageData[index] == 0)
      {
        pixels.setPixelColor(index, pixels.Color(255, 0, 0));
      }
      else if (imageData[index] == 1)
      {
        pixels.setPixelColor(index, pixels.Color(0, 255, 0));
      }
      else if (imageData[index] == 2)
      {
        pixels.setPixelColor(index, pixels.Color(0, 0, 255));
      }
    }
    pixels.show();
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// TEST
void processTest()
{
  for (int i = 0; i < 45 + 17 + 45 + 17; i++)
  {
    pixels.setPixelColor(i, 255, 0, 0);
    pixels.show();
    delay(10);
  }
}

/// Main loop
void loop()
{
  // processSingleByteColors();
  // process3ByteColor();
  processSerial();
  // processTest();
}