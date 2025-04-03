using Network.Session;

namespace Core.GameObjects;

public static class ObjectClientListener
{
    public interface Attached
    {
        public void ObjectAttached(NetworkSession session);
    }
    public interface Detached
    {
        public void ObjectDetached(NetworkSession session);
    }

    
    public interface Loaded
    {
        public void ObjectLoadedToClient(NetworkSession session);
    }

    public interface Unloaded
    {
        public void ObjectUnloadedFromClient(NetworkSession session);
    }
}