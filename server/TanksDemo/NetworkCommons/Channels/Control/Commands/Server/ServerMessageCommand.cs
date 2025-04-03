using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Server;

internal sealed class ServerMessageCommand(string message) : IControlCommand
{
    public byte CommandId => 11;

    public readonly string Message = message;
    
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        throw new InvalidOperationException();
    }
}

[CustomCodec(typeof(ServerMessageCommand))]
sealed class ServerMessageCommandCodec : ICustomCodec
{
    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        GeneralDataEncoder.Encode(0, output, nullMap);
        GeneralDataEncoder.Encode(((ServerMessageCommand)data).Message, output, nullMap);
    }
    public object Decode(ByteArray input, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}