using Core.Model;

namespace Platform.Models.General.World3d.View3d;

[ModelEntity(typeof(View3DEntity))]
[Model]
internal class View3DModel(long id) : ModelBase<object>(id), IClientConstructor<View3DCC>
{
    public View3DCC GetClientInitData()
    {
        View3DEntity entity = GetEntity<View3DEntity>();
        
        return new View3DCC()
        {
            Position = entity.CameraPosition,
            Rotation = entity.CameraRotation
        };
    }
}