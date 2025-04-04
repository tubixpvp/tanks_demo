using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(long))]
public class LongCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadLong();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteLong((long)data);
    }
}