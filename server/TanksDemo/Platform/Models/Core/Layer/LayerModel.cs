using Core.Model;

namespace Platform.Models.Core.Layer;

[ModelEntity(typeof(LayerModelEntity))]
[Model]
public class LayerModel(long id) : ModelBase<ILayerModelClient>(id)
{
    
}