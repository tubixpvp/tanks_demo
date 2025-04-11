using Core.GameObjects;
using Core.Spaces;
using Network.Session;

namespace Core.Model;

public class ModelContext(GameObject gameObject, NetworkSession? session)
{
    private static readonly object Lock = new();
    
    public static void RunLocked(Action action)
    {
        lock (Lock)
        {
            action();
        }
    }


    public GameObject Object { get; private set; } = gameObject;
    public NetworkSession? Session { get; private set; } = session;
    
    public Space Space => Object.Space;


    public void Set(GameObject gameObject, NetworkSession? session)
    {
        Object = gameObject;
        Session = session;
    }
    
}