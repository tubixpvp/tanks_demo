using Core.GameObjects;
using Core.Model;
using Network.Session;
using Platform.Models.Core.Parent;

namespace Platform.Models.Core.Child;

[ModelEntity(typeof(ChildModelEntity))]
[Model]
internal class ChildModel(long id) : ModelBase<IChildModelClient>(id), IChild, ObjectAttachListener.Attached
{
    public void ObjectAttached(NetworkSession session)
    {
        Clients(Context, client => 
            client.InitObject(GetParent().Id));
    }

    public GameObject GetParent()
    {
        return GetEntity<ChildModelEntity>().Parent;
    }

    public void ChangeParent(GameObject newParent)
    {
        GameObject childObject = Context.Object;
        
        ChildModelEntity entity = GetEntity<ChildModelEntity>();

        GameObject oldParent = entity.Parent;
        oldParent.GetModelEntity<ParentEntity>().Children.TryRemove(childObject.Id, out _);

        entity.Parent = newParent;
        newParent.GetModelEntity<ParentEntity>().Children.TryAdd(childObject.Id, childObject);
        
        Clients(Context.Object, Context.Space.GetDeployedSessions(Context.Object),
            client => client.ChangeParent(newParent.Id));
    }
}