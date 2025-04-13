using Core.Model;

namespace Projects.Tanks.Models.Map;

[ModelEntity(typeof(MapModelEntity))]
[Model]
public class MapModel(long id) : ModelBase<object>(id)
{
    
}