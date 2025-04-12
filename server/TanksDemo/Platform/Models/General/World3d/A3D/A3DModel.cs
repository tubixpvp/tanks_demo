using Core.GameObjects;
using Core.Model;
using GameResources;
using OSGI.Services;

namespace Platform.Models.General.World3d.A3D;

[ModelEntity(typeof(A3DModelEntity))]
[Model]
internal class A3DModel(long id) : ModelBase<IA3DModelClient>(id), ObjectListener.Load, IResourceRequire
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    public void ObjectLoaded()
    {
        A3DModelEntity entity = GetEntity<A3DModelEntity>();

        long collisionResourceId = entity.CollisionResourceId == null ? 0 : 
            ResourceRegistry.GetNumericId(entity.CollisionResourceId);
        
        Clients(Context, client => 
            client.InitObject(
                a3dResourceId:ResourceRegistry.GetNumericId(entity.ModelResourceId),
                collisionResourceId:collisionResourceId
                ));
    }

    public void CollectGameResources(List<string> resourcesIds)
    {
        A3DModelEntity entity = GetEntity<A3DModelEntity>();

        resourcesIds.Add(entity.ModelResourceId);
        
        if(entity.CollisionResourceId != null)
            resourcesIds.Add(entity.CollisionResourceId);
    }
}