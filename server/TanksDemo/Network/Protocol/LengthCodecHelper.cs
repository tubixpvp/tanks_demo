using Utils;

namespace Network.Protocol;

public static class LengthCodecHelper
{
    public static int DecodeLength(ByteArray input)
    {
        byte firstByte = input.ReadByte();

        bool singleByte = ((firstByte & 0x80) == 0);
        if (singleByte)
        {
            return firstByte;
        }

        byte secondByte = input.ReadByte();
        bool doubleByte = (firstByte & 0x40) == 0;
        if (doubleByte)
        {
            return ((firstByte & 0x3F) << 8) + (secondByte & 0xFF);
        }

        int thirdByte = input.ReadByte();
        return ((firstByte & 0x3F) << 16) + (secondByte << 8) + (thirdByte & 0xFF);
    }

    public static void EncodeLength(ByteArray output, int length)
    {
        if (length < 0)
        {
            throw new Exception("Length is incorrect (" + length + ")");
        }

        if (length < 128)
        {
            output.WriteByte(length & 0x7F);
            return;
        }

        if (length < 16384)
        {
            int tmp = (length & 0x3FFF) + 0x8000;
            output.WriteByte((tmp & 0xFF00) >> 8);
            output.WriteByte(tmp & 0xFF);
            return;
        }

        if (length < 4194304)
        {
            int tmp = (length & 0x3FFFFF) + 0xC00000;
            output.WriteByte((tmp & 0xFF0000) >> 16);
            output.WriteByte((tmp & 0xFF00) >> 8);
            output.WriteByte(tmp & 0xFF);
            return;
        }

        throw new Exception("Length is incorrect (" + length + ")");
    }
}