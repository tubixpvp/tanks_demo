using System.Collections.Concurrent;
using Core.GameObjects;

namespace Platform.Models.Core.Parent;

public class ParentEntity
{
    public ConcurrentDictionary<string, GameObject> Children { get; } = new();
}