using System.Collections.Concurrent;
using Logging;
using Network.Channels;
using Network.Protocol;
using Network.Session;
using NetworkCommons.Channels.Control.Commands.Server;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control;

[Service]
public class ControlChannelHandler : IChannelPacketHandler, IOSGiInitListener
{
    [InjectService]
    private static PacketChannelsService PacketChannelsService;

    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static CodecsRegistry CodecsRegistry;


    public event Action<NetworkSession>? OnControlSessionInited;
    public event SessionClosedDelegate? OnControlSessionClosed;
    
    
    private const string SessionIdKey = "SessionId";

    private readonly ConcurrentDictionary<string, NetworkSession> _controlSessions = new();


    private ILogger _logger;


    public void OnOSGiInited()
    {
        _logger = LoggerService.GetLogger(GetType());
        
        PacketChannelsService.AddHandler(ProtocolChannelType.Control, this);
    }
    
    public Task HandleConnect(NetworkSession session)
    {
        return Task.CompletedTask;
    }
    
    public string? GetSessionId(NetworkSession session)
    {
        return session.GetAttribute<string?>(SessionIdKey)!;
    }
    public NetworkSession GetSessionById(string sessionId)
    {
        return _controlSessions[sessionId];
    }
    
    public Task HandleDisconnect(NetworkSession session)
    {
        string? sessionId = GetSessionId(session);
        if (sessionId != null)
        {
            _controlSessions.TryRemove(sessionId, out _);
        }
        
        Task? task = OnControlSessionClosed?.Invoke(session);
        
        return task ?? Task.CompletedTask;
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

    internal void SendCommand(IControlCommand command, NetworkSession session)
    {
        SendCommand(command, [session]);
    }
    internal void SendCommand(IControlCommand command, IEnumerable<NetworkSession> sessions)
    {
        ByteArray sendBuffer = ByteArrayPool.Get();
        NullMap nullMap = new NullMap();
        
        NetPacket packet = new NetPacket(sendBuffer, nullMap);
        
        ICustomCodec commandCodec = CodecsRegistry.GetCodec(command.GetType())!;

        GeneralDataEncoder.Encode(command.CommandId, packet);

        commandCodec.Encode(command, sendBuffer, nullMap);

        Task task = Task.WhenAll(sessions.Select(
            session => SafeTask.AddListeners(
                session.Socket.SendPacket(packet), session.OnError)));

        task.ContinueWith(_ => ByteArrayPool.Put(sendBuffer));
    }

    private IControlCommand[] DecodeCommands(NetPacket packet)
    {
        List<IControlCommand> commands = new();
        
        while (packet.PacketBuffer.BytesAvailable > 0)
        {
            byte commandId = GeneralDataDecoder.Decode<byte>(packet);

            _logger.Log(LogLevel.Debug, "Decoding control command, id=" + commandId);

            Type? commandType = ControlCommands.GetClientCommandType(commandId);

            if (commandType == null)
            {
                throw new Exception("Control command not found! Id = " + commandId);
            }

            ICustomCodec commandCodec = CodecsRegistry.GetCodec(commandType)!;
            
            commands.Add((IControlCommand)commandCodec.Decode(packet.PacketBuffer,packet.NullMap));
        }

        return commands.ToArray();
    }


    internal string SetupAsControlSession(NetworkSession session)
    {
        session.ChannelType = ProtocolChannelType.Control;
        
        string sessionId;
        do
        {
            sessionId = Guid.NewGuid().ToString("N");
        } while (!_controlSessions.TryAdd(sessionId, session));

        session.SetAttribute(SessionIdKey, sessionId);
        
        _logger.Log(LogLevel.Info, 
            $"Connection IP:{session.Socket.IPAddress} has joined CONTROL channel with sessionID:{sessionId}");

        return sessionId;
    }

    internal void OnHashAccepted(NetworkSession session)
    {
        OnControlSessionInited?.Invoke(session);
    }

    public void SendOpenSpace(NetworkSession session)
    {
        SendCommand(new OpenSpaceCommand(), session);
    }

    public delegate Task SessionClosedDelegate(NetworkSession controlSession);
}