using Core.Model;
using GameResources;
using OSGI.Services;

namespace Platform.Models.General.World3d.A3D;

[ModelEntity(typeof(A3DModelEntity))]
[Model]
internal class A3DModel(long id) : ModelBase<object>(id), IClientConstructor<A3DModelCC>, IResourceRequire
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;


    public void CollectGameResources(List<string> resourcesIds)
    {
        A3DModelEntity entity = GetEntity<A3DModelEntity>();

        resourcesIds.Add(entity.ModelResourceId);
        
        if(entity.CollisionResourceId != null)
            resourcesIds.Add(entity.CollisionResourceId);
    }

    public A3DModelCC GetClientInitData()
    {
        A3DModelEntity entity = GetEntity<A3DModelEntity>();

        long collisionResourceId = entity.CollisionResourceId == null ? 0 : 
            ResourceRegistry.GetNumericId(entity.CollisionResourceId);

        return new A3DModelCC()
        {
            A3dResourceId = ResourceRegistry.GetNumericId(entity.ModelResourceId),
            CollisionResourceId = collisionResourceId
        };
    }
}