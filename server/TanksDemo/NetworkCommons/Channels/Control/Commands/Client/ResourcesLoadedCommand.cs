using Network.Protocol;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

internal class ResourcesLoadedCommand(int batchId) : IControlCommand
{
    [InjectService]
    private static IClientResourceLoadListener LoadListener;
    
    
    public const byte CommandID = 7;

    public byte CommandId => CommandID;
    
    public async Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        LoadListener.OnResourceLoaded(session, batchId);
    }
    
}

[CustomCodec(typeof(ResourcesLoadedCommand))]
class ResourcesLoadedCommandCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        int batchId = GeneralDataDecoder.Decode<int>(input, nullMap);
        
        return new ResourcesLoadedCommand(batchId);
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}