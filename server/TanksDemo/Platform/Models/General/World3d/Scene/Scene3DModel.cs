using Core.Model;

namespace Platform.Models.General.World3d.Scene;

[ModelEntity(typeof(Scene3DEntity))]
[Model]
internal class Scene3DModel(long id) : ModelBase<object>(id)
{
}