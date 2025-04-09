using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(short))]
internal class ShortCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadShort();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteShort((short)data);
    }
}