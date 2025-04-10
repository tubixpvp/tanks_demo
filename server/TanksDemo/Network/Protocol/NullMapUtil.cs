using Utils;

namespace Network.Protocol;

public static class NullMapUtil
{
    private const byte InplaceMaskFlag = 0x80;
    private const byte MaskLength2BytesFlag = 0x40;
    
    private const byte InplaceMask1Bytes = 0x20;
    private const byte InplaceMask2Bytes = 0x40;
    private const byte InplaceMask3Bytes = 0x60;
    
    private const byte MaskLength1Byte = 0x80;
    private const int MaskLegth3Byte = 0xC00000;
    
    
    public static NullMap DecodeNullMap(ByteArray input)
    {
        byte firstByte = input.ReadByte();
        
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
                byte secondByte = input.ReadByte();
                byte thirdByte = input.ReadByte();
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


    public static void EncodeNullMap(NullMap nullMap, ByteArray output)
    {
        int nullMapSize = nullMap.GetSize();
        byte[] map = nullMap.GetMap();
        if (nullMapSize <= 5)
        {
            output.WriteByte((map[0] & 0xFF) >>> 3);
            return;
        }

        if (nullMapSize <= 13)
        {
            output.WriteByte((((map[0] & 0xFF) >>> 3) + InplaceMask1Bytes));
            output.WriteByte((((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
            return;
        }

        if (nullMapSize <= 21)
        {
            output.WriteByte((((map[0] & 0xFF) >>> 3) + InplaceMask2Bytes));
            output.WriteByte((((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
            output.WriteByte((((map[2] & 0xFF) >>> 3) + (map[1] << 5)));
            return;
        }

        if (nullMapSize <= 29)
        {
            output.WriteByte((((map[0] & 0xFF) >>> 3) + InplaceMask3Bytes));
            output.WriteByte((((map[1] & 0xFF) >>> 3) + (map[0] << 5)));
            output.WriteByte((((map[2] & 0xFF) >>> 3) + (map[1] << 5)));
            output.WriteByte((((map[3] & 0xFF) >>> 3) + (map[2] << 5)));
            return;
        }

        if (nullMapSize <= 504)
        {
            int sizeInBytes = (nullMapSize >>> 3) + ((nullMapSize & 0x07) == 0 ? 0 : 1);
            int firstByte = ((sizeInBytes & 0xFF) + MaskLength1Byte);
            output.WriteByte(firstByte);
            output.WriteBytes(map, 0, sizeInBytes);
            return;
        }

        if (nullMapSize <= 33554432)
        {
            int sizeInBytes = (nullMapSize >>> 3) + ((nullMapSize & 0x07) == 0 ? 0 : 1);
            int sizeEncoded = sizeInBytes + MaskLegth3Byte;
            int firstByte = ((sizeEncoded & 0xFF0000) >>> 16);
            int secondByte = ((sizeEncoded & 0xFF00) >>> 8);
            int thirdByte = (sizeEncoded & 0xFF);
            output.WriteByte(firstByte);
            output.WriteByte(secondByte);
            output.WriteByte(thirdByte);
            output.WriteBytes(map, 0, sizeInBytes);
            return;
        }

        throw new Exception("NullMap overflow");
    }
}