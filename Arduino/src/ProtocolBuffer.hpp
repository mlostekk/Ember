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

public:
    /// Constructor
    ProtocolBuffer();
    /// Write one byte, return true if this byte was an
    /// protocol end byte and going back the protocol length
    /// found a start byte
    bool putByte(const byte element);
    /// Get the current protocol chunk
    Protocol getProtocolChunk();
};

/// Construction
template <size_t S, size_t PL, byte PS, byte PE>
ProtocolBuffer<S, PL, PS, PE>::ProtocolBuffer() : writeIndex(-1)
{
    for (uint16_t index = 0; index < S; index++)
    {
        buffer[index] = 0;
    }
}

/// Put byte
template <size_t S, size_t PL, byte PS, byte PE>
bool ProtocolBuffer<S, PL, PS, PE>::putByte(const byte element)
{
    writeIndex = (writeIndex + 1) % S;
    buffer[writeIndex] = element;
    if (element == PE)
    {
        return true;
    }
    return false;
}

/// Construction
template <size_t S, size_t PL, byte PS, byte PE>
typename ProtocolBuffer<S, PL, PS, PE>::Protocol ProtocolBuffer<S, PL, PS, PE>::getProtocolChunk()
{
    // return chunk
    Protocol protocol = { PL, {}};
    // early exit
    if (buffer[writeIndex] != PE)
    {
        for (uint16_t index = 0; index < PL; index++)
        {
            protocol.buffer[index] = 0;
        }
        return protocol;
    }
    // regular processing
    for (uint16_t index = 0; index < PL; index++)
    {
        int readIndex = writeIndex - PL + index;
        if (readIndex < 0)
        {
            readIndex = S + readIndex;
        }
        protocol.buffer[index] = buffer[readIndex];
    }
    return protocol;
}

#endif /* __ProtocolBuffer_H__ */
