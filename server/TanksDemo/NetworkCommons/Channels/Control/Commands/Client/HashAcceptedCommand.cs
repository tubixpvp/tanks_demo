using Logging;
using Network.Protocol;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

[CustomCodec(typeof(HashAcceptedCommand))]
public class HashAcceptedCommand : IControlCommand, ICustomCodec
{
    public const byte CommandID = 4;

    public byte CommandId => CommandID;
    
    public async Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        string? sessionId = channelHandler.GetSessionId(session);

        if (sessionId == null) //not requested -> not got hash
        {
            return;
        }
        
        OSGi.GetService<LoggerService>().GetLogger(GetType()).Log(LogLevel.Debug, 
            $"Client sessionId:{sessionId} accepted hash!");

        channelHandler.OnHashAccepted(session);
    }

    
    public object Decode(ByteArray input, NullMap nullMap)
    {
        return new HashAcceptedCommand();
    }
    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}