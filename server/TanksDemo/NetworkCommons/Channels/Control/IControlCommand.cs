using Network.Session;

namespace NetworkCommons.Channels.Control;

internal interface IControlCommand
{
    public Task Execute(ControlCommandChannelHandler channelHandler, NetworkSession session);
}