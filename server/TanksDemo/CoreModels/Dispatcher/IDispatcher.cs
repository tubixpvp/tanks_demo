using Core.GameObjects;
using Network.Session;

namespace CoreModels.Dispatcher;

public interface IDispatcher
{
    public void LoadEntities(GameObject[] objects, IEnumerable<NetworkSession> sessions);
    public void UnloadEntities(GameObject[] objects, IEnumerable<NetworkSession> sessions);
}