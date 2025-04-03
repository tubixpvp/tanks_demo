using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Server;

[CustomCodec(typeof(OpenSpaceCommand))]
internal class OpenSpaceCommand : IControlCommand, ICustomCodec
{
    public byte CommandId => 3;
    
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        throw new InvalidOperationException();
    }
    
    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
    }
    public object Decode(ByteArray input, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}