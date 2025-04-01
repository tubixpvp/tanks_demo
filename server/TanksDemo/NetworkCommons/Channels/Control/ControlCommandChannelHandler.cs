using System.Collections.Concurrent;
using Logging;
using Network.Channels;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;

namespace NetworkCommons.Channels.Control;

[Service]
public class ControlCommandChannelHandler : IChannelPacketHandler, IOSGiInitListener
{
    [InjectService]
    private static PacketChannelsService PacketChannelsService;

    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static CodecsRegistry CodecsRegistry;


    private const string SessionIdKey = "ControlSessionId";

    private readonly ConcurrentDictionary<string, NetworkSession> _controlSessions = new();


    private ILogger _logger;


    public void OnOSGiInited()
    {
        _logger = LoggerService.GetLogger(GetType());
        
        PacketChannelsService.AddHandler(ProtocolChannelType.Control, this);
    }
    
    public Task HandleConnect(NetworkSession session)
    {
        string sessionId;
        do
        {
            sessionId = Guid.NewGuid().ToString("N");
        } while (_controlSessions.ContainsKey(sessionId));

        session.SetAttribute(SessionIdKey, sessionId);
        
        _logger.Log(LogLevel.Info, 
            $"Connection IP:{session.Socket.IPAddress} has joined CONTROL channel with ID:{sessionId}");

        return Task.CompletedTask;
    }
    public string GetSessionId(NetworkSession session)
    {
        return session.GetAttribute<string?>(SessionIdKey)!;
    }
    
    public Task HandleDisconnect(NetworkSession session)
    {
        string sessionId = GetSessionId(session);
        _controlSessions.TryRemove(sessionId, out _);

        return Task.CompletedTask;
    }
    
    public async Task HandlePacket(NetworkSession session, NetPacket packet)
    {
        _logger.Log(LogLevel.Debug, "HandlePacket()");
        
        packet.ResetPosition();

        IControlCommand[] commands = DecodeCommands(packet);

        foreach (IControlCommand command in commands)
        {
            await command.Execute(this, session);
        }
    }

    internal void SendCommand(IControlCommand command)
    {
        //TODO implement
    }

    private IControlCommand[] DecodeCommands(NetPacket packet)
    {
        List<IControlCommand> commands = new();
        
        while (packet.PacketBuffer.BytesAvailable > 0)
        {
            byte commandId = GeneralDataDecoder.Decode<byte>(packet);

            _logger.Log(LogLevel.Debug, "Decoding control command, id=" + commandId);

            Type? commandType = ControlCommands.GetCommandType(commandId);

            if (commandType == null)
            {
                throw new Exception("Control command not found! Id = " + commandId);
            }

            ICustomCodec commandCodec = CodecsRegistry.GetCodec(commandType)!;
            
            commands.Add((IControlCommand)commandCodec.Decode(packet.PacketBuffer,packet.NullMap));
        }

        return commands.ToArray();
    }
}