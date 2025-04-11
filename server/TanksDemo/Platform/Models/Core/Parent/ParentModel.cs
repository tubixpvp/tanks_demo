using Core.GameObjects;
using Core.Model;

namespace Platform.Models.Core.Parent;

[ModelEntity(typeof(ParentEntity))]
[Model]
internal class ParentModel(long id) : ModelBase<object>(id), IParent
{
    
    public GameObject? GetChild(string name)
    {
        return GetEntity().Children.Values.FirstOrDefault(obj => obj.Name == name);
    }
    public GameObject? GetChild(long id)
    {
        return GetEntity().Children.GetValueOrDefault(id);
    }

    public GameObject[] GetChildren()
    {
        return GetEntity().Children.Values.ToArray();
    }

    private ParentEntity GetEntity() => GetEntity<ParentEntity>();
    
}