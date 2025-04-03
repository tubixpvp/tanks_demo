using Core.GameObjects;
using Network.Session;

namespace Core.Model.Communication;

public interface IModelCommunicationService
{
    public void GetSender<CI>(
        GameObject gameObject,
        IEnumerable<NetworkSession> sessions,
        Action<CI> callback);
}