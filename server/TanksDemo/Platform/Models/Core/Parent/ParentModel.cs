using Core.GameObjects;
using Core.Model;

namespace Platform.Models.Core.Parent;

[ModelEntity(typeof(ParentEntity))]
[Model]
internal class ParentModel(long id) : ModelBase<object>(id), IParent
{
    
    public GameObject? GetChild(string name)
    {
        ParentEntity entity = GetEntity();
        lock (entity.Children)
        {
            return entity.Children.FirstOrDefault(obj => obj.Name == name);
        }
    }
    public GameObject? GetChild(long id)
    {
        ParentEntity entity = GetEntity();
        lock (entity.Children)
        {
            return entity.Children.FirstOrDefault(obj => obj.Id == id);
        }
    }

    public GameObject[] GetChildren()
    {
        ParentEntity entity = GetEntity();
        lock (entity.Children)
        {
            return entity.Children.ToArray();
        }
    }

    public void CollectAllChildrenLevels(List<GameObject> children)
    {
        children.Add(Context.Object);

        ParentEntity entity = GetEntity();
        lock (entity.Children)
        {
            foreach (GameObject child in entity.Children)
            {
                IParent? parent = child.TryAdapt<IParent>();
                if (parent != null)
                    parent.CollectAllChildrenLevels(children);
                else
                    children.Add(child);
            }
        }
    }

    private ParentEntity GetEntity() => GetEntity<ParentEntity>();
    
}