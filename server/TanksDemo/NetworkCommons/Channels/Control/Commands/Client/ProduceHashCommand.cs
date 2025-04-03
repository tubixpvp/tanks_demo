using System.Text;
using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

internal class ProduceHashCommand(byte[] hashBytes) : IControlCommand
{
    public const byte CommandID = 0;

    public byte CommandId => CommandID;
    
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        string? sessionId = channelHandler.GetSessionId(session);

        if (sessionId != null)
        {
            return Task.CompletedTask; //already inited as CONTROL session
        }
        
        sessionId = Encoding.UTF8.GetString(hashBytes);

        channelHandler.SetupAsSpaceSession(session, sessionId);
        
        return Task.CompletedTask;
    }
    
}

[CustomCodec(typeof(ProduceHashCommand))]
class ProduceHashCommandCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        byte[] hashBytes = input.ReadBytes(32);
        return new ProduceHashCommand(hashBytes);
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}