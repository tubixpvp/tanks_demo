using Logging;
using Network.Protocol;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

[CustomCodec(typeof(HashRequestCommand))]
internal sealed class HashRequestCommand : IControlCommand, ICustomCodec
{
    [InjectService]
    private static LoggerService LoggerService;
    
    
    public const byte CommandId = 1;
    
    public Task Execute(ControlCommandChannelHandler channelHandler, NetworkSession session)
    {
        ILogger logger = LoggerService.GetLogger(GetType());

        string sessionId = channelHandler.GetSessionId(session);

        logger.Log(LogLevel.Debug, "Request, sessionId = " + sessionId);
        
        //TODO
        //channelHandler.SendCommand(new HashResponseCommand());
        
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