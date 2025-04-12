using Core.GameObjects;
using Core.Model;

namespace Platform.Models.General.World3d.View3d;

[ModelEntity(typeof(View3DEntity))]
[Model]
internal class View3DModel(long id) : ModelBase<IView3DModelClient>(id), ObjectListener.Load
{
    public void ObjectLoaded()
    {
        View3DEntity entity = GetEntity<View3DEntity>();
        
        Clients(Context, client =>
            client.InitObject(entity.CameraPosition,entity.CameraRotation));
    }
}