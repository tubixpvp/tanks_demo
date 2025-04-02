using Network.Session;

namespace NetworkCommons.Channels.Control;

internal interface IControlCommand
{
    public byte CommandId { get; }
    public Task Execute(ControlCommandChannelHandler channelHandler, NetworkSession session);
}