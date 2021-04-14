#include "catch.hpp"
#include "ProtocolBuffer.hpp"

#define PS 254
#define PE 255
#define PL 3
#define INVALID_PROTOCOL \
    {                    \
        0, 0, 0          \
    }

struct TestValue
{
    short value;
    bool endSignal;
    byte protocol[PL];
};

SCENARIO("ProtocolBuffer tests")
{
    GIVEN("A basic buffer, 5 length, protocol 3 long, 254 start, 255 end")
    {
        ProtocolBuffer<10, PL, PS, PE> buffer;

        //  idx: |   0	 1	 2	 3	 4	 5	 6	 7	 8
        // ------┼--------------------------------------
        //  val: |  10	11	PS	 1	 2	 3	PE	12	13
        WHEN("Filling the sequence 10 11 254 1 2 3 255 12 13, the correct result needs to be found")
        {
            // TestValue values[] = {
            //     {10, false, INVALID_PROTOCOL},
            //     {11, false, INVALID_PROTOCOL},
            //     {PS, false, INVALID_PROTOCOL},
            //     {1, false, INVALID_PROTOCOL},
            //     {2, false, INVALID_PROTOCOL},
            //     {3, false, INVALID_PROTOCOL},
            //     {PE, true, {1, 2, 3}},
            //     {12, false, INVALID_PROTOCOL},
            //     {13, false, INVALID_PROTOCOL},
            // };
            // for (int index = 0; index < 9; index++)
            // {
            //     TestValue value = values[index];
            //     bool endSignal = buffer.putByte(value.value);
            //     REQUIRE(endSignal == value.endSignal);
            //     auto resultProtocol = buffer.getProtocolChunk();
            //     REQUIRE(resultProtocol.buffer[0] == value.protocol[0]);
            //     REQUIRE(resultProtocol.buffer[1] == value.protocol[1]);
            //     REQUIRE(resultProtocol.buffer[2] == value.protocol[2]);
            // }

            // 10
            {
                bool endSignal = buffer.putByte(10);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // 11
            {
                bool endSignal = buffer.putByte(11);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // S
            {
                bool endSignal = buffer.putByte(PS);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // 1
            {
                bool endSignal = buffer.putByte(1);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // 2
            {
                bool endSignal = buffer.putByte(2);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // 3
            {
                bool endSignal = buffer.putByte(3);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // E
            {
                bool endSignal = buffer.putByte(PE);
                REQUIRE(endSignal == true);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 1);
                REQUIRE(resultProtocol.buffer[1] == 2);
                REQUIRE(resultProtocol.buffer[2] == 3);
            }

            // 12
            {
                bool endSignal = buffer.putByte(12);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }

            // 13
            {
                bool endSignal = buffer.putByte(13);
                REQUIRE(endSignal == false);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == 0);
                REQUIRE(resultProtocol.buffer[1] == 0);
                REQUIRE(resultProtocol.buffer[2] == 0);
            }
        }

        //  idx: |   0	 1	 2	 3	 4	 5	 6	 7	 8
        // ------┼--------------------------------------
        //  val: |  10	11	 S	 1	 2	 3	 E	12	13
        WHEN("Filling the sequence 10 11 254 1 2 3 255 12 13, (in a different way) the correct result needs to be found")
        {
            TestValue values[] = {
                {10, false, INVALID_PROTOCOL},
                {11, false, INVALID_PROTOCOL},
                {PS, false, INVALID_PROTOCOL},
                {1, false, INVALID_PROTOCOL},
                {2, false, INVALID_PROTOCOL},
                {3, false, INVALID_PROTOCOL},
                {PE, true, {1, 2, 3}},
                {12, false, INVALID_PROTOCOL},
                {13, false, INVALID_PROTOCOL},
            };
            for (int index = 0; index < 9; index++)
            {
                TestValue value = values[index];
                bool endSignal = buffer.putByte(value.value);
                REQUIRE(endSignal == value.endSignal);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == value.protocol[0]);
                REQUIRE(resultProtocol.buffer[1] == value.protocol[1]);
                REQUIRE(resultProtocol.buffer[2] == value.protocol[2]);
            }
        }

        //  idx: |   0	 1	 2	 3	 4	 5	 6	 7	 8
        // ------┼--------------------------------------
        //  val: |   3	PE	10	11 	12	13	PS	 1	 2
        WHEN("Filling the sequence 10 11 254 1 2 3 255 12 13, the correct result needs to be found")
        {
            TestValue values[] = {
                {99, false, INVALID_PROTOCOL}, // dummy
                {99, false, INVALID_PROTOCOL}, // dummy
                {99, false, INVALID_PROTOCOL}, // dummy
                {10, false, INVALID_PROTOCOL},
                {11, false, INVALID_PROTOCOL},
                {12, false, INVALID_PROTOCOL},
                {13, false, INVALID_PROTOCOL},
                {PS, false, INVALID_PROTOCOL},
                {1, false, INVALID_PROTOCOL},
                {2, false, INVALID_PROTOCOL},
                {3, false, INVALID_PROTOCOL},
                {PE, true, {1, 2, 3}},
            };
            for (int index = 0; index < 12; index++)
            {
                TestValue value = values[index];
                bool endSignal = buffer.putByte(value.value);
                REQUIRE(endSignal == value.endSignal);
                auto resultProtocol = buffer.getProtocolChunk();
                REQUIRE(resultProtocol.buffer[0] == value.protocol[0]);
                REQUIRE(resultProtocol.buffer[1] == value.protocol[1]);
                REQUIRE(resultProtocol.buffer[2] == value.protocol[2]);
            }
        }
    }
}