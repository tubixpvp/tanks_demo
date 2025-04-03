using Core.GameObjects;
using Network.Session;

namespace Core.Model;

public class ModelContext(GameObject gameObject, NetworkSession? session)
{
    public static readonly object Lock = new();
    
    
    public GameObject Object => gameObject;
    public NetworkSession? Session => session;
}