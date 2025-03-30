using Network.Channels;
using Network.Sockets;

namespace Network.Session;

public class NetworkSession
{
    public NetSocket Socket { get; }

    internal ProtocolChannelType ChannelType { get; set; }
    
    
    internal NetworkSession(NetSocket socket)
    {
        Socket = socket;
        ChannelType = ProtocolChannelType.Control;
    }
}