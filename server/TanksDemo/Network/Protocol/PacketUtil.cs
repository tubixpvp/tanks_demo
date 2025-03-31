using Utils;

namespace Network.Protocol;

internal static class PacketUtil
{
    
    private const byte ZippedFlag = 0x40;
    private const byte LengthFlag = 0x80;

    private const byte InplaceMaskFlag = 0x80;
    private const byte MaskLength2BytesFlag = 0x40;


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

    public static NullMap DecodeNullMap(ByteArray input)
    {
        sbyte firstByte = input.ReadSByte();
        
        bool isLongNullMap = (firstByte & InplaceMaskFlag) != 0;

        int firstByteValue;
        int maskLength;
        if (isLongNullMap)
        {
            firstByteValue = (firstByte & 0x3F);

            bool isLength22bit = (firstByte & MaskLength2BytesFlag) != 0;
            
            if (isLength22bit)
            {
                // размерность длины 22 бит
                int secondByte = input.ReadByte();
                int thirdByte = input.ReadByte();
                maskLength = (firstByteValue << 16) + (secondByte << 8) + (thirdByte & 0xFF);
            }
            else
            {
                // размерность длины 6 бит
                maskLength = firstByteValue;
            }

            int sizeInBits = maskLength << 3;
            return new NullMap(sizeInBits, input.ReadBytes(maskLength));
        }
        
        firstByteValue = firstByte << 3;
		
        maskLength = (firstByte & 0x60) >> 5;
        
        switch (maskLength) {
            case 0:
                return new NullMap(5, [(byte)firstByteValue]);
            case 1:
                byte secondByte = input.ReadByte();
                return new NullMap(13, [
                    (byte)(firstByteValue + ((secondByte & 0xFF) >>> 5)),
                    (byte)(secondByte << 3)
                ]);
            case 2:
                secondByte = input.ReadByte();
                byte thirdByte = input.ReadByte();
                return new NullMap(21, [
                    (byte)((firstByteValue) + ((secondByte & 0xFF) >>> 5)),
                    (byte)((secondByte << 3) + ((thirdByte & 0xFF) >>> 5)),
                    (byte)(thirdByte << 3)
                ]);
            case 3:
                secondByte = input.ReadByte();
                thirdByte = input.ReadByte();
                byte fourthByte = input.ReadByte();
                return new NullMap(29, [
                    (byte)((firstByteValue) + ((secondByte & 0xFF) >>> 5)),
                    (byte)((secondByte << 3) + ((thirdByte & 0xFF) >>> 5)),
                    (byte)((thirdByte << 3) + ((fourthByte & 0xFF) >>> 5)),
                    (byte)(fourthByte << 3)
                ]);
        }

        throw new Exception("NullMap decoding error. MaskLength=" + maskLength);
    }
}