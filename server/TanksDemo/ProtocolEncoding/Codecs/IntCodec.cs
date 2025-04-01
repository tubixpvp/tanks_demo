using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(int))]
internal class IntCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadInt();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteInt((int)data);
    }
}