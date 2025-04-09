using Network.Protocol;
using ProtocolEncoding;
using Utils;

namespace GameResources.Codec;

[CustomCodec(typeof(ResourceInfo))]
internal class ResourceInfoCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        ResourceInfo info = (ResourceInfo)data;

        GeneralDataEncoder.Encode(info.NumericId, output, nullMap);
        GeneralDataEncoder.Encode(info.NumericVersion, output, nullMap);
        
        GeneralDataEncoder.Encode((short)info.Type, output, nullMap);

        GeneralDataEncoder.Encode(false, output, nullMap);
    }
}