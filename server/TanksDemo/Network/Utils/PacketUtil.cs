using Utils;

namespace Network.Utils;

internal static class PacketUtil
{
    
    private const byte ZippedFlag = 0x40;
    private const byte LengthFlag = 0x80;


    public static bool UnwrapPacket(ByteArray input, ByteArray output)
    {
        if (input.BytesAvailable < 2)
            return false;
        sbyte flagByte = input.ReadSByte();
        
        bool longLength = (flagByte & LengthFlag) != 0;

        bool zipped;
        int packetSize;
        
        if (longLength)
        {
            if (input.BytesAvailable < 3)
                return false;

            zipped = true;
            
            int hiByte = (flagByte ^ LengthFlag) << 24;
            int middleByte = (input.ReadSByte() & 0xFF) << 16;
            int loByte = (input.ReadSByte() & 0xFF) << 8;
            int loByte2 = (input.ReadSByte() & 0xFF);
            
            packetSize = hiByte + middleByte + loByte + loByte2;
        }
        else
        {
            zipped = (flagByte & ZippedFlag) != 0;
            int hiByte = (flagByte & 0x3F) << 8;
            int loByte = (input.ReadSByte() & 0xFF);
            packetSize = hiByte + loByte;
        }

        if (input.BytesAvailable < packetSize)
            return false;

        byte[] packetBytes = input.ReadBytes(packetSize);
        
        if (zipped)
        {
            packetBytes = CompressionUtil.UncompressZLib(packetBytes);
        }

        output.WriteBytes(packetBytes);

        return true;
    }
}