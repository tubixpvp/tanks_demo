using Network.Session;

namespace NetworkCommons.Channels.Control.Commands.Client;

public interface IClientResourceLoadListener
{
    public void OnResourceLoaded(NetworkSession controlSession, int batchId);
}