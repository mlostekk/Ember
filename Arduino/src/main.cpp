#include <Arduino.h>
#include <RingBuf.h>
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
const bool SEND_VERBOSE = false;
const bool SEND_INDEX_ERROR = true;
const bool SEND_SUCCESS = false;

/// The neopixel instance
Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

RingBuf<byte, 500> ringBuffer;

///////////////////////////
// array[512] = buffer
// // read
// PROTO_LEN = NUMPIXELS * 3
// INDEX = INDEX % 512
// write byte in array at INDEX
// when by == END_CHAR
//   read ELEMENT at INDEX - PROTO_LEN + 1 (incl wrapping)
//   when ELEMENT == START_CHAR
//     take RESULT ranging from (INDEX - PROTO_LEN) until (INDEX - 1) (as loop) -> LED
// INDEX + 1

// | | | | | | | | | | | |
// |5 6 E x x x x S 2 3 4|  -> 2 3 4 5 6 is the correct sequence
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
    if (SEND_DEBUG)
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// PRINT RING
void printRingBuffer()
{
  if (!SEND_VERBOSE)
  {
    return;
  }
  Serial.print("ring(");
  Serial.print(ringBuffer.size());
  Serial.print("): ");
  for(uint16_t index = 0; index < ringBuffer.size(); index++) 
  {
    Serial.print(ringBuffer[index]);
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
  bool somethingToRead = false;
  while (Serial.available() > 0)
  {
    somethingToRead = true;
    byte incoming = Serial.read();
    printNum("incoming: %i", incoming);
    auto success = ringBuffer.push(incoming);
    if (!success)
    {
      if (SEND_DEBUG)
      {
        Serial.println("ERROR PUTTING RING BUFFER");
      }
      ringBuffer.clear();
    }
    printRingBuffer();
  }
  // Serial.println("proceed");
  // check if there is somethig to read
  if(!somethingToRead) 
  {
    return;
  }
  // check if ring buffer is full
  if (ringBuffer.isFull())
  {
    if (SEND_DEBUG)
    {
      Serial.println("ringbuffer is full, dropping last");
    }
    byte last;
    ringBuffer.pop(last);
  }
  // try to find a PROTOCOL_END_CHAR
  int startIndex = -1;
  int endIndex = -1;
  for (uint16_t index = 0; index < ringBuffer.size(); index++)
  {
    if (ringBuffer[index] == PROTOCOL_START_CHAR)
    {
      startIndex = index;
      if (endIndex > 0)
      {
        break;
      }
    }
    if (ringBuffer[index] == PROTOCOL_END_CHAR)
    {
      endIndex = index;
      if (startIndex > 0)
      {
        break;
      }
    }
  }
  // no end index
  if (endIndex < 0)
  {
    return;
  }

  // start index behind end index?
  if (startIndex >= endIndex)
  {
    if (SEND_INDEX_ERROR)
    {
      Serial.println("start index behind end index, purging");
    }
    ringBuffer.clear();
    return;
  }
  // end index found
  if (endIndex >= 0 && startIndex < 0)
  {
    if (SEND_INDEX_ERROR)
    {
      Serial.println("end index without start index, purging");
    }
    ringBuffer.clear();
    return;
  }

  // check if the amount of bytes is correct
  if (SEND_SUCCESS)
  {
    Serial.print("protocol chars found found (");
    Serial.print(startIndex);
    Serial.print(" / ");
    Serial.print(endIndex);
    Serial.println(")");
  }
  // pop first elements
  for(int index = 0; index <= startIndex; index++)
  {
    byte startCharByte;
    ringBuffer.pop(startCharByte);
  }
  // process elements
  uint16_t range = (endIndex - startIndex) - 1;
  byte element[range];
  for (uint16_t idx = 0; idx < range; idx++)
  {
    ringBuffer.pop(element[idx]);
  }
  // pop last element
  byte endCharByte;
  ringBuffer.pop(endCharByte);
  // print
  printArray(element, range);
  printRingBuffer();

  if (SEND_SUCCESS)
  {
    Serial.print("chunk lengh: ");
    Serial.println(range);
  }
  Serial.flush();

  // set leds
  setLeds(element, range);
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