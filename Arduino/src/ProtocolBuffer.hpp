#ifndef __ProtocolBuffer_H__
#define __ProtocolBuffer_H__

// #include <Arduino.h>

typedef uint8_t byte;

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

/**
 * S  - Total size of the buffer
 * PL - Protocol length 
 * PS - Protocol start byte
 * PE - Protocol end byte 
 */
template <size_t S, size_t PL, byte PS, byte PE>
class ProtocolBuffer
{
    struct Protocol
    {
        size_t size;
        byte buffer[PL];
    };

    /*
     * check the size is greater than 0, otherwise emit a compile time error
     */
    static_assert(S > 0, "RingBuf with size 0 are forbidden");

    /*
     * check the size is lower or equal to the maximum uint16_t value,
     * otherwise emit a compile time error
     */
    static_assert(S <= UINT16_MAX, "RingBuf with size greater than 65535 are forbidden");

private:
    byte buffer[S];
    int writeIndex;
    int startIndex; //last found PS

public:
    /// Constructor
    ProtocolBuffer();
    /// Write one byte, return true if this byte was an
    /// protocol end byte and going back the protocol length
    /// found a start byte
    bool putByte(const byte element);
    /// Get the current protocol chunk
    Protocol getProtocolChunk();
    /// Purge the whole buffer
    void purge();
};

/// Construction
template <size_t S, size_t PL, byte PS, byte PE>
ProtocolBuffer<S, PL, PS, PE>::ProtocolBuffer()
{
    purge();
}

/// Put byte
template <size_t S, size_t PL, byte PS, byte PE>
bool ProtocolBuffer<S, PL, PS, PE>::putByte(const byte element)
{
    // 1. start element
    if (element == PS)
    {
        startIndex = writeIndex;
    }
    // 2. increment index and save new element
    buffer[writeIndex] = element;
    writeIndex = (writeIndex + 1) % S;
    // 3. end elmeent?
    if (element == PE)
    {
        // check here if there is a valid start element
        int expectedStart = (writeIndex - 2 - PL);
        if (expectedStart < 0)
        {
            expectedStart += S;
        }
        if (expectedStart == startIndex)
        {
            return true;
        }
        //forget last found PS
        startIndex = -1;
        return false;
    }
    return false;
}

/// Get the current protocol chunk
template <size_t S, size_t PL, byte PS, byte PE>
typename ProtocolBuffer<S, PL, PS, PE>::Protocol ProtocolBuffer<S, PL, PS, PE>::getProtocolChunk()
{
    // return chunk
    Protocol protocol = {PL, {}};

    int readIndex = (writeIndex - 1) % S;
    int expectedStart = (readIndex - 1 - PL);
    if (expectedStart < 0)
    {
        expectedStart += S;
    }
    //is the last Protocol-start and Protocol-end at the expected position
    if (buffer[readIndex] == PE && expectedStart == startIndex)
    {
        // regular processing
        for (uint16_t index = 0; index < PL; index++)
        {
            int fetchIndex = readIndex - PL + index;
            if (fetchIndex < 0)
            {
                fetchIndex = S + fetchIndex;
            }
            protocol.buffer[index] = buffer[fetchIndex];
        }
        //forget last found PS
        startIndex = -1;
    } else {
        for (uint16_t index = 0; index < PL; index++)
        {
            protocol.buffer[index] = 0;
        }
    }
    return protocol;
}

/// Purging
template <size_t S, size_t PL, byte PS, byte PE>
void ProtocolBuffer<S, PL, PS, PE>::purge()
{
    writeIndex = 0;
    startIndex = -1;
    for (uint16_t index = 0; index < S; index++)
    {
        buffer[index] = 0;
    }
}

#endif /* __ProtocolBuffer_H__ */
