using Network.Channels;
using Network.Sockets;
using OSGI.Services;

namespace Network.Session;

public class NetworkSession
{
    [InjectService]
    private static PacketChannelsService PacketChannels;
    
    public NetSocket Socket { get; }

    internal ProtocolChannelType ChannelType { get; set; }
    
    
    internal NetworkSession(NetSocket socket)
    {
        Socket = socket;
        ChannelType = ProtocolChannelType.Control;

        socket.OnPacketReceived += OnPacketBytesReceived;
    }

    public void Init()
    {
        Socket.StartReading();
    }

    private async Task OnPacketBytesReceived(NetPacket packet)
    {
        Task? task = PacketChannels.HandlePacket(this, packet);
        if (task != null)
        {
            await task;
        }
    }
}