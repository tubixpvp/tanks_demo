using System.Collections.Concurrent;
using Logging;
using Network.Channels;
using Network.Sockets;
using OSGI.Services;

namespace Network.Session;

public class NetworkSession
{
    [InjectService]
    private static PacketChannelsService PacketChannels;

    [InjectService]
    private static LoggerService LoggerService;
    
    
    public NetSocket Socket { get; }

    public ProtocolChannelType ChannelType { get; set; }


    private readonly ILogger _logger;


    private readonly ConcurrentDictionary<string, object> _attributes = new();
    
    
    internal NetworkSession(NetSocket socket)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        Socket = socket;
        ChannelType = ProtocolChannelType.Control;

        socket.OnPacketReceived += OnPacketBytesReceived;
        socket.OnDisconnected += OnDisconnected;
        socket.OnError += OnError;
    }

    public async Task Init()
    {
        Socket.StartReading();

        await PacketChannels.HandleConnect(this);
    }

    private async Task OnPacketBytesReceived(NetPacket packet)
    {
        _logger.Log(LogLevel.Debug, 
            $"New packet received from {Socket.IPAddress} -> packetDataSize={packet.PacketBuffer.Length}, nullMapSize={packet.NullMap.GetSize()}");
        
        await PacketChannels.HandlePacket(this, packet);
    }

    private async Task OnDisconnected()
    {
        await PacketChannels.HandleDisconnect(this);
    }

    public void OnError(Exception e)
    {
        _logger.Log(LogLevel.Error, e.ToString());
    }


    public void SetAttribute(string key, object value) => _attributes[key] = value;
    public T? GetAttribute<T>(string key) => (T?)_attributes.GetValueOrDefault(key);

    
}