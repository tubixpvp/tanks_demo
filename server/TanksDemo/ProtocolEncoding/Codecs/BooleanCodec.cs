using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(bool))]
internal class BooleanCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadByte() != 0;
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteByte(((bool)data) ? 1 : 0);
    }
}