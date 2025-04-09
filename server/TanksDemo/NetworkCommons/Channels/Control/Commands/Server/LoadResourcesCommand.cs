using GameResources;
using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Server;

internal class LoadResourcesCommand(int batchId, ResourceInfo[][] resources) : IControlCommand
{
    public byte CommandId => 5;


    public readonly int BatchId = batchId;
    public readonly ResourceInfo[][] Resources = resources;
    
    
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        throw new InvalidOperationException();
    }
}

[CustomCodec(typeof(LoadResourcesCommand))]
internal class LoadResourcesCommandCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        LoadResourcesCommand command = (LoadResourcesCommand)data;
        
        GeneralDataEncoder.Encode(command.BatchId, output, nullMap);

        GeneralDataEncoder.Encode(command.Resources, output, nullMap);
    }
}