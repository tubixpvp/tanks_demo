using Core.GameObjects;
using Core.Model;
using CoreModels.Dispatcher;
using Network.Session;

namespace CoreModels.GameObjectLoader;

[ModelEntity(typeof(GameObjectLoaderEntity))]
[Model(ServerOnly = true)]
internal class GameObjectLoaderModel(long id) : ModelBase<object>(id), ObjectClientListener.Attached
{
    public void ObjectAttached(NetworkSession session)
    {
        IDispatcher dispatcher = Context.Object.Space.GetRootObject().Adapt<IDispatcher>();
        
        //test
        dispatcher.LoadEntities([Context.Object], [session]);
    }
}