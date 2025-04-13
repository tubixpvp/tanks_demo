using Core.Model;

namespace Platform.Models.Core.Layer;

[ModelEntity(typeof(LayerModelEntity))]
[Model]
internal class LayerModel(long id) : ModelBase<object>(id), IClientConstructor<LayerModelCC>
{
    public LayerModelCC GetClientInitData()
    {
        return new LayerModelCC()
        {
            Layer = GetEntity<LayerModelEntity>().Layer
        };
    }
}