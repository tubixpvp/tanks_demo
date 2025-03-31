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

    internal ProtocolChannelType ChannelType { get; set; }


    private readonly ILogger _logger;
    
    
    internal NetworkSession(NetSocket socket)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        Socket = socket;
        ChannelType = ProtocolChannelType.Control;

        socket.OnPacketReceived += OnPacketBytesReceived;
        socket.OnDisconnected += OnDisconnected;
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
}