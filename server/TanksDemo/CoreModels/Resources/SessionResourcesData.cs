using System.Collections.Concurrent;

namespace CoreModels.Resources;

internal class SessionResourcesData
{
    public int LoadCounter { get; set; }

    public readonly ConcurrentDictionary<int, Action> LoadCallbacks = new();
}