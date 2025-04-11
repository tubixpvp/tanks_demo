using Network.Session;
using Utils;

namespace Core.GameObjects;

/**
 * Events related to loading the GameObject on client
 */
public static class ObjectDeployListener
{
    public interface Deploy
    {
        public void DeployObject(NetworkSession session, SimpleCancelToken cancelToken);
    }
    public interface Deployed
    {
        /**
         * Calls when GameObject is loaded to client
         */
        public void ObjectDeployed(NetworkSession session);
    }
}