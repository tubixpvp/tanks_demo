using System.Collections.Concurrent;
using Core.GameObjects;

namespace CoreModels.GameObjectLoader;

internal class GameObjectDeployListeners
{
    public readonly ConcurrentDictionary<GameObject,List<Action>> Listeners = new();
}