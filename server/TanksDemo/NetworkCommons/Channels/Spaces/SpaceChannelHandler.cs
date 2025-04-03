using Core.Spaces;
using Logging;
using Network.Channels;
using Network.Session;
using NetworkCommons.Channels.Control;
using OSGI.Services;

namespace NetworkCommons.Channels.Spaces;

[Service]
public class SpaceChannelHandler : IChannelPacketHandler, IOSGiInitListener
{
    [InjectService]
    private static PacketChannelsService PacketChannelsService;
    
    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static ControlChannelHandler ControlChannelHandler;
    
    
    public event Action<NetworkSession>? OnSpaceSessionInited;
    
    
    private const string ControlSessionIdKey = "ControlSessionId";
    
    private const string SpacesDataKey = "SpacesData";
    
    
    private readonly Dictionary<string, List<NetworkSession>> _spaceSessionsById = new();

    
    private ILogger _logger;
    
    public void OnOSGiInited()
    {
        _logger = LoggerService.GetLogger(GetType());
        
        PacketChannelsService.AddHandler(ProtocolChannelType.Space, this);

        ControlChannelHandler.OnControlSessionClosed += OnControlSessionClosed;
    }
    
    public async Task HandlePacket(NetworkSession session, NetPacket packet)
    {
        //todo
        
        _logger.Log(LogLevel.Debug, "New space packet");
    }

    public Task HandleConnect(NetworkSession spaceSession)
    {
        string sessionId = GetControlSessionId(spaceSession)!;
        NetworkSession controlSession = ControlChannelHandler.GetSessionById(sessionId);
        
        SessionSpacesData spacesData = GetControlSessionData(controlSession);

        if (spacesData.ConnectingSpace == null)
        {
            throw new Exception("Not waiting for any space connections");
        }

        List<NetworkSession>? spaceSessions;
        lock (_spaceSessionsById)
        {
            if (!_spaceSessionsById.TryGetValue(sessionId, out spaceSessions))
            {
                _spaceSessionsById.Add(sessionId, spaceSessions = new List<NetworkSession>());
            }
        }

        lock (spaceSessions)
        {
            spaceSessions.Add(spaceSession);
        }

        Space space = spacesData.ConnectingSpace;
        spacesData.ConnectingSpace = null;

        space.AddSession(spaceSession);

        spacesData.ConnectedSpaces.TryAdd(spaceSession, space);

        
        lock (spacesData.SpacesToConnect)
        {
            if (spacesData.SpacesToConnect.TryDequeue(out Space? queuedSpace))
            {
                ConnectToSpace(controlSession, queuedSpace);
            }
        }
        
        return Task.CompletedTask;
    }

    private Task OnControlSessionClosed(NetworkSession controlSession)
    {
        string sessionId = GetControlSessionId(controlSession)!;

        NetworkSession[] spaceSessions;
        lock (_spaceSessionsById)
        {
            if (!_spaceSessionsById.TryGetValue(sessionId, out var sessions))
            {
                return Task.CompletedTask;
            }
            spaceSessions = sessions.ToArray(); //cache the array
        }

        return Task.WhenAll(spaceSessions.Select(HandleDisconnect));
    }
    public Task HandleDisconnect(NetworkSession spaceSession)
    {
        string sessionId = GetControlSessionId(spaceSession)!;
        NetworkSession controlSession = ControlChannelHandler.GetSessionById(sessionId);

        lock (_spaceSessionsById)
        {
            if (_spaceSessionsById.TryGetValue(sessionId, out var spaceSessions))
            {
                lock (spaceSessions)
                {
                    spaceSessions.Remove(spaceSession);
                }
            }
        }
        
        SessionSpacesData spacesData = GetControlSessionData(controlSession);

        spacesData.ConnectedSpaces.TryRemove(spaceSession, out Space? space);

        space!.RemoveSession(spaceSession);
        
        return Task.CompletedTask;
    }

    public NetworkSession GetControlSessionBySpace(NetworkSession spaceSession)
    {
        string sessionId = GetControlSessionId(spaceSession)!;
        NetworkSession controlSession = ControlChannelHandler.GetSessionById(sessionId);
        return controlSession;
    }
    
    public void ConnectToSpace(NetworkSession controlSession, Space space)
    {
        SessionSpacesData spacesData = GetControlSessionData(controlSession);

        if (spacesData.ConnectingSpace != null)
        {
            lock (spacesData.SpacesToConnect)
            {
                spacesData.SpacesToConnect.Enqueue(space);
            }

            return;
        }
        
        spacesData.ConnectingSpace = space;
        
        ControlChannelHandler.SendOpenSpace(controlSession);
    }

    private static SessionSpacesData GetControlSessionData(NetworkSession controlSession)
    {
        SessionSpacesData? data = controlSession.GetAttribute<SessionSpacesData>(SpacesDataKey);

        if (data == null)
        {
            data = new SessionSpacesData();
            controlSession.SetAttribute(SpacesDataKey, data);
        }

        return data;
    }
    
    public string? GetControlSessionId(NetworkSession session)
    {
        return session.GetAttribute<string?>(ControlSessionIdKey)!;
    }
    
    internal void SetupAsSpaceSession(NetworkSession session, string sessionId)
    {
        session.ChannelType = ProtocolChannelType.Space;
        
        session.SetAttribute(ControlSessionIdKey, sessionId);
        
        _logger.Log(LogLevel.Info, 
            $"Connection IP:{session.Socket.IPAddress} has joined SPACE channel with sessionID:{sessionId}");
        
        OnSpaceSessionInited?.Invoke(session);
    }
    
}