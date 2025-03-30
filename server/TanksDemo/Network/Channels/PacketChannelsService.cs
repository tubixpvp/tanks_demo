using Network.Session;
using OSGI.Services;

namespace Network.Channels;

[Service]
public class PacketChannelsService
{
    private readonly Dictionary<ProtocolChannelType, PacketHandleDelegate> _handlers = new();


    public void AddHandler(ProtocolChannelType type, PacketHandleDelegate handler)
    {
        if (!_handlers.ContainsKey(type))
        {
            _handlers.Add(type, handler);
            return;
        }
        _handlers[type] += handler;
    }
    
    public Task? HandlePacket(NetworkSession session, NetPacket packet)
    {
        PacketHandleDelegate handlerEvent = _handlers[session.ChannelType];
        
        return handlerEvent?.Invoke(session, packet);
    }

    public delegate Task PacketHandleDelegate(NetworkSession session, NetPacket packet);
}