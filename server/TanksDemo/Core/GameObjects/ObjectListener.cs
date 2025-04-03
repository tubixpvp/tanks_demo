namespace Core.GameObjects;

public static class ObjectListener
{
    public interface Load
    {
        public void ObjectLoaded();
    }

    public interface Unload
    {
        public void ObjectUnloaded();
    }
}