using Network.Session;

namespace NetworkCommons.Channels.Control;

internal interface IControlCommand
{
    public byte CommandId { get; }
    public Task Execute(ControlChannelHandler channelHandler, NetworkSession session);
}