using Core.GameObjects;
using Core.Model;
using Network.Session;

namespace Core.Models.Dispatcher;

[ModelEntity(typeof(DispatcherEntity))]
[Model]
internal class DispatcherModel(long modelId) : ModelBase<IDispatcherModelClient>(1), ObjectClientListener.Attached
{
    
    public void ObjectAttached(NetworkSession session)
    {
        Clients(Context.Object, [session], client => client.InitSpace(Context.Object.Space.Id));
    }
    
}