﻿namespace Utils;

public enum ByteEndian
{
    BigEndian,
    LittleEndian
}
public class ByteArray
{
    public long Length => _stream.Length;
    public long Position {get=>_stream.Position;set=>_stream.Position=value;}
    public long BytesAvailable => _stream.Length - _stream.Position;
    
    private readonly MemoryStream _stream;
    
    private readonly BinaryReader _reader;
    private readonly BinaryWriter _writer;
    
    public ByteArray(byte[]? buffer = null, ByteEndian endian = ByteEndian.BigEndian)
    {
        _stream = buffer != null ? new MemoryStream(buffer) : new MemoryStream();

        _reader = endian == ByteEndian.BigEndian ? new BigEndianBinaryReader(_stream) : new BinaryReader(_stream);
        _writer = endian == ByteEndian.BigEndian ? new BigEndianBinaryWriter(_stream) : new BinaryWriter(_stream);
    }

    public void WriteLong(long value) => _writer.Write(value);
    public void WriteInt(int value) => _writer.Write(value);
    
    public void WriteBytes(byte[] buffer) => _writer.Write(buffer);
    public void WriteBytes(byte[] buffer, int offset, int count) => _writer.Write(buffer, offset, count);


    public int ReadInt() => _reader.ReadInt32();
    public uint ReadUInt() => _reader.ReadUInt32();
    public short ReadShort() => _reader.ReadInt16();
    public ushort ReadUShort() => _reader.ReadUInt16();
    public byte ReadByte() => _reader.ReadByte();
    public sbyte ReadSByte() => _reader.ReadSByte();
    
    public byte[] ReadBytes(long count) => _reader.ReadBytes((int)count);

    public void Clear()
    {
        _stream.Position = 0;
        _stream.SetLength(0);
    }
}