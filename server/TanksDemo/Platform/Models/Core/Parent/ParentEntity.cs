using System.Collections.Concurrent;
using Core.GameObjects;

namespace Platform.Models.Core.Parent;

public class ParentEntity
{
    public ConcurrentDictionary<long, GameObject> Children { get; } = new();
}