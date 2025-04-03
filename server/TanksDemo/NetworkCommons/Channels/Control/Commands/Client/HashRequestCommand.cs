using System.Text;
using Logging;
using Network.Protocol;
using Network.Session;
using NetworkCommons.Channels.Control.Commands.Server;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

[CustomCodec(typeof(HashRequestCommand))]
internal sealed class HashRequestCommand : IControlCommand, ICustomCodec
{
    [InjectService]
    private static LoggerService LoggerService;
    
    public const byte CommandID = 1;

    public byte CommandId => CommandID;
    
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        string? sessionId = channelHandler.GetSessionId(session);

        if (sessionId != null) //already got it's hash
        {
            return Task.CompletedTask;
        }

        sessionId = channelHandler.SetupAsControlSession(session);

        byte[] hashBytes = Encoding.UTF8.GetBytes(sessionId);

        channelHandler.SendCommand(new HashResponseCommand(hashBytes), session);
        
        return Task.CompletedTask;
    }
    
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return new HashRequestCommand();
    }
    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}