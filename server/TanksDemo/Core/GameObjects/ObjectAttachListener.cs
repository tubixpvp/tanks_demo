using Network.Session;

namespace Core.GameObjects;

public static class ObjectAttachListener
{
    public interface Attached
    {
        public void ObjectAttached(NetworkSession session);
    }
    public interface Detached
    {
        public void ObjectDetached(NetworkSession session);
    }
}