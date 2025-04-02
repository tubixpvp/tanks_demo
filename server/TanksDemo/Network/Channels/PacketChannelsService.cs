using Network.Session;
using OSGI.Services;
using Utils;

namespace Network.Channels;

[Service]
public class PacketChannelsService
{
    
    private readonly Dictionary<ProtocolChannelType, HandlerEntry> _handlers = new();

    public void AddHandler(ProtocolChannelType type, IChannelPacketHandler handler)
    {
        HandlerEntry entry = GetHandler(type);
        entry.HandlePacket += handler.HandlePacket;
        entry.HandleConnect += handler.HandleConnect;
        entry.HandleDisconnect += handler.HandleDisconnect;
    }

    private HandlerEntry GetHandler(ProtocolChannelType type)
    {
        if (!_handlers.TryGetValue(type, out var entry))
        {
            _handlers.Add(type, entry = new HandlerEntry());
        }
        return entry;
    }
    
    public async Task HandlePacket(NetworkSession session, NetPacket packet)
    {
        Task? task = GetHandler(session.ChannelType).HandlePacket?.Invoke(session, packet);
        if (task != null)
        {
            await SafeTask.AddListeners(task, session.OnError);
        }
    }

    public async Task HandleConnect(NetworkSession session)
    {
        Task? task = GetHandler(session.ChannelType).HandleConnect?.Invoke(session);
        if (task != null)
        {
            await SafeTask.AddListeners(task, session.OnError);
        }
    }
    public async Task HandleDisconnect(NetworkSession session)
    {
        Task? task = GetHandler(session.ChannelType).HandleDisconnect?.Invoke(session);
        if (task != null)
        {
            await SafeTask.AddListeners(task, session.OnError);
        }
    }

    class HandlerEntry
    {
        public HandlePacketDelegate? HandlePacket { get; set; }
        public HandleSessionEventDelegate? HandleConnect { get; set; }
        public HandleSessionEventDelegate? HandleDisconnect { get; set; }
    }
    
    private delegate Task HandlePacketDelegate(NetworkSession session, NetPacket packet);
    private delegate Task HandleSessionEventDelegate(NetworkSession session);
    
}