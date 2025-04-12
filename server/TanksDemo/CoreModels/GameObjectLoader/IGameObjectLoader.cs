using Network.Session;

namespace CoreModels.GameObjectLoader;

internal interface IGameObjectLoader
{
    public void AddDeployListener(NetworkSession session, Action callback);
}