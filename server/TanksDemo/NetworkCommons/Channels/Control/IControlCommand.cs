using Network.Session;

namespace NetworkCommons.Channels.Control;

public interface IControlCommand
{
    public byte CommandId { get; }
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session);
}