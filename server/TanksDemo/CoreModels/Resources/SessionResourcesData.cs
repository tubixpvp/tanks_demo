using System.Collections.Concurrent;
using GameResources;

namespace CoreModels.Resources;

internal class SessionResourcesData
{
    public int LoadCounter { get; set; }

    public readonly ConcurrentDictionary<int, Action> LoadCallbacks = new();
    public readonly ConcurrentDictionary<int, ResourceInfo[]> LoadingResources = new();

    public readonly List<ResourceInfo> LoadedResources = new();
}