using Core.GameObjects;

namespace Platform.Models.Core.Parent;

public class ParentEntity
{
    public List<GameObject> Children { get; } = new();
}