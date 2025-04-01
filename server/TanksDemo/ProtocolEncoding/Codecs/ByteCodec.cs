using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(byte))]
internal class ByteCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadByte();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteByte((byte)data);
    }
}