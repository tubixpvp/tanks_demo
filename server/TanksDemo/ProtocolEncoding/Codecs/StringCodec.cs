using System.Text;
using Network.Protocol;
using Utils;

namespace ProtocolEncoding.Codecs;

[CustomCodec(typeof(string))]
internal class StringCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        int length = LengthCodecHelper.DecodeLength(input);
        return input.ReadUTFBytes(length);
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        byte[] stringBytes = Encoding.UTF8.GetBytes((string)data);

        LengthCodecHelper.EncodeLength(output, stringBytes.Length);

        output.WriteBytes(stringBytes);
    }
}