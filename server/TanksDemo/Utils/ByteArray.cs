namespace Utils;

public enum ByteEndian
{
    BigEndian,
    LittleEndian
}
public class ByteArray
{
    public long Length => _stream.Length;
    public long Position {get=>_stream.Position;set=>_stream.Position=value;}
    
    private readonly MemoryStream _stream;
    
    private readonly BinaryReader _reader;
    private readonly BinaryWriter _writer;
    
    public ByteArray(byte[]? buffer = null, ByteEndian endian = ByteEndian.BigEndian)
    {
        _stream = buffer != null ? new MemoryStream(buffer) : new MemoryStream();

        _reader = endian == ByteEndian.BigEndian ? new BigEndianBinaryReader(_stream) : new BinaryReader(_stream);
        _writer = endian == ByteEndian.BigEndian ? new BigEndianBinaryWriter(_stream) : new BinaryWriter(_stream);
    }

    public void WriteLong(long value)
    {
        _writer.Write(value);
    }

    public void WriteInt(int value) => _writer.Write(value);


    public int ReadInt()
    {
        return _reader.ReadInt32();
    }

    public uint ReadUInt()
    {
        return _reader.ReadUInt32();
    }

    public short ReadShort()
    {
        return _reader.ReadInt16();
    }

    public ushort ReadUShort() => _reader.ReadUInt16();

    public byte ReadByte()
    {
        return _reader.ReadByte();
    }

    public sbyte ReadSByte()
    {
        return _reader.ReadSByte();
    }

    public void Clear()
    {
        _stream.Position = 0;
        _stream.SetLength(0);
    }
}