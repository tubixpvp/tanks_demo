using Network.Protocol;
using Utils;

namespace ProtocolEncoding;

public interface ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap);
    public void Encode(object data, ByteArray output, NullMap nullMap);
}