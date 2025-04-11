using Core.GameObjects;
using Utils;

namespace Core.Spaces;

internal class SessionSpaceData
{
    public readonly List<GameObject> AttachedObjects = new();
    
    public readonly Dictionary<GameObject, SimpleCancelToken> DeployingObjects = new();
    public readonly List<GameObject> DeployedObjects = new();
}