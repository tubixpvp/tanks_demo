using Core.GameObjects;
using Core.Model;
using Platform.Models.Core.Parent;

namespace Platform.Models.Core.Child;

[ModelEntity(typeof(ChildModelEntity))]
[Model]
internal class ChildModel(long id) : ModelBase<IChildModelClient>(id), IClientConstructor<ChildCC>, IChild
{
    
    public GameObject GetParent()
    {
        return GetEntity<ChildModelEntity>().Parent!;
    }

    public void ChangeParent(GameObject newParent)
    {
        GameObject childObject = Context.Object;
        
        ChildModelEntity entity = GetEntity<ChildModelEntity>();

        if (entity.Parent != null)
        {
            ParentEntity oldParentEntity = entity.Parent.GetModelEntity<ParentEntity>();
            lock (oldParentEntity.Children)
            {
                oldParentEntity.Children.Remove(childObject);
            }
        }

        entity.Parent = newParent;
        ParentEntity newParentEntity = newParent.GetModelEntity<ParentEntity>();
        lock (newParentEntity.Children)
        {
            newParentEntity.Children.Add(childObject);
        }
        
        Clients(Context.Object, Context.Space.GetDeployedSessions(Context.Object),
            client => client.ChangeParent(newParent.Id));
    }

    public ChildCC GetClientInitData()
    {
        return new ChildCC()
        {
            ParentId = GetParent().Id
        };
    }
}