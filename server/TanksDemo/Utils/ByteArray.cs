using System.Text;

namespace Utils;

public enum ByteEndian
{
    BigEndian,
    LittleEndian
}
public class ByteArray : IDisposable
{
    public long Length => _stream.Length;
    public long Position {get=>_stream.Position;set=>_stream.Position=value;}
    public long BytesAvailable => _stream.Length - _stream.Position;
    
    public ByteEndian Endian { get; }
    
    
    private readonly MemoryStream _stream;
    
    private readonly BinaryReader _reader;
    private readonly BinaryWriter _writer;
    
    public ByteArray(byte[]? buffer = null, ByteEndian endian = ByteEndian.BigEndian)
    {
        Endian = endian;
        
        _stream = buffer != null ? new MemoryStream(buffer) : new MemoryStream();

        _reader = endian == ByteEndian.BigEndian ? new BigEndianBinaryReader(_stream) : new BinaryReader(_stream);
        _writer = endian == ByteEndian.BigEndian ? new BigEndianBinaryWriter(_stream) : new BinaryWriter(_stream);
    }

    public void Dispose()
    {
        _reader.Dispose();
        _writer.Dispose();
        _stream.Dispose();
    }

    public void WriteLong(long value) => _writer.Write(value);
    public void WriteInt(int value) => _writer.Write(value);
    public void WriteByte(byte value) => _writer.Write(value);
    public void WriteByte(int value) => _writer.Write((byte)value);
    
    public void WriteBytes(byte[] buffer) => _writer.Write(buffer);
    public void WriteBytes(byte[] buffer, int offset, int count) => _writer.Write(buffer, offset, count);
    public void WriteBytes(ByteArray bytes) => _writer.Write(bytes.ToArray());


    public int ReadInt() => _reader.ReadInt32();
    public uint ReadUInt() => _reader.ReadUInt32();
    public short ReadShort() => _reader.ReadInt16();
    public ushort ReadUShort() => _reader.ReadUInt16();
    public byte ReadByte() => _reader.ReadByte();
    public sbyte ReadSByte() => _reader.ReadSByte();
    public long ReadLong() => _reader.ReadInt64();
    
    public byte[] ReadBytes(long count) => _reader.ReadBytes((int)count);
    
    public string ReadUTFBytes(long length) => Encoding.UTF8.GetString(ReadBytes(length));
    
    public byte[] ToArray() => _stream.ToArray();

    public void Clear()
    {
        _stream.Position = 0;
        _stream.SetLength(0);
    }
}