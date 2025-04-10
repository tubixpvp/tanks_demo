using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(float))]
internal class FloatCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return input.ReadFloat();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteFloat((float)data);
    }
}