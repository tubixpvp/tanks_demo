using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using Core.Spaces;
using Logging;
using Network.Channels;
using Network.Session;
using NetworkCommons.Channels.Control;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

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

    [InjectService]
    private static IModelCommunicationService ModelCommunicationService;
    
    
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
    
    public async Task HandlePacket(NetworkSession spaceSession, NetPacket packet)
    {
        packet.ResetPosition();
        
        ByteArray buffer = packet.PacketBuffer;

        if (buffer.BytesAvailable == 0)
            return;

        SessionSpacesData spacesData = GetControlSessionData(GetControlSessionBySpace(spaceSession));
        Space space = spacesData.ConnectedSpaces[spaceSession];

        ModelContext? context = null;

        while (buffer.BytesAvailable > 0)
        {
            long objectId = GeneralDataDecoder.Decode<long>(packet);
            long methodId = GeneralDataDecoder.Decode<long>(packet);
            
            _logger.Log(LogLevel.Debug, $"New space packet: objectId={objectId}, methodId={methodId}");

            GameObject gameObject = space.ObjectsStorage.GetObject(objectId)!;

            if (context == null)
                context = new ModelContext(gameObject, spaceSession);
            else
                context.Set(gameObject, spaceSession);

            await ModelCommunicationService.InvokeServerMethod(context, methodId, packet);
        }
    }

    public async Task HandleConnect(NetworkSession spaceSession)
    {
        if (spaceSession.ChannelType == ProtocolChannelType.Control)
            return;
        
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

        spacesData.ConnectedSpaces.TryAdd(spaceSession, space);
        
        space.AddSession(spaceSession);

        
        lock (spacesData.SpacesToConnect)
        {
            if (spacesData.SpacesToConnect.TryDequeue(out Space? queuedSpace))
            {
                ConnectToSpace(controlSession, queuedSpace);
            }
        }
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
    public async Task HandleDisconnect(NetworkSession spaceSession)
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
    }

    public NetworkSession GetControlSessionBySpace(NetworkSession spaceSession)
    {
        string sessionId = GetControlSessionId(spaceSession)!;
        NetworkSession controlSession = ControlChannelHandler.GetSessionById(sessionId);
        return controlSession;
    }

    public NetworkSession? GetSpaceSession(NetworkSession controlSession, Space spaceConnected)
    {
        SessionSpacesData spacesData = GetControlSessionData(controlSession);

        foreach ((NetworkSession spaceSession, Space space) in spacesData.ConnectedSpaces)
        {
            if (space == spaceConnected)
            {
                return spaceSession;
            }
        }

        return null;
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

    public void DisconnectFromSpace(NetworkSession controlSession, NetworkSession spaceSession)
    {
        spaceSession.Socket.Disconnect();
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
    
    internal async Task SetupAsSpaceSession(NetworkSession session, string sessionId)
    {
        session.ChannelType = ProtocolChannelType.Space;
        
        session.SetAttribute(ControlSessionIdKey, sessionId);
        
        _logger.Log(LogLevel.Info, 
            $"Connection IP:{session.Socket.IPAddress} has joined SPACE channel with sessionID:{sessionId}");

        await HandleConnect(session);
    }


    internal void SendCommand(SpaceCommand command, IEnumerable<NetworkSession> sessions)
    {
        ByteArray sendBuffer = ByteArrayPool.Get();
        NetPacket packet = new NetPacket(sendBuffer, command.NullMap);

        GeneralDataEncoder.Encode(command.ObjectId, packet);
        GeneralDataEncoder.Encode(command.MethodId, packet);

        sendBuffer.WriteBytes(command.DataBuffer);

        _logger.Log(LogLevel.Debug, 
            $"Sending space command: objectId={command.ObjectId}, methodId={command.MethodId}, dataBuffLen={command.DataBuffer.Length}, sendBuffLen={sendBuffer.Length}, nullMapSize={packet.NullMap.GetSize()}");
        
        Task task = Task.WhenAll(sessions.Select(
            session => SafeTask.AddListeners(
                session.Socket.SendPacket(packet), session.OnError)));

        task.ContinueWith(_ =>
        {
            command.Dispose();
            ByteArrayPool.Put(sendBuffer);
        });
    }
    
}