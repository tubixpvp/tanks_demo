using Core.GameObjects;
using Core.Model;

namespace Platform.Models.Core.Layer;

[ModelEntity(typeof(LayerModelEntity))]
[Model]
internal class LayerModel(long id) : ModelBase<ILayerModelClient>(id), ObjectListener.Load
{
    public void ObjectLoaded()
    {
        Clients(Context, client => 
            client.InitObject(GetEntity<LayerModelEntity>().Layer));
    }
}