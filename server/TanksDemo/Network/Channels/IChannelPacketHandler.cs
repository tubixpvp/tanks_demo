using Network.Session;

namespace Network.Channels;

public interface IChannelPacketHandler
{
    public Task HandlePacket(NetworkSession session, NetPacket packet);

    public Task HandleConnect(NetworkSession session);
    public Task HandleDisconnect(NetworkSession session);
}