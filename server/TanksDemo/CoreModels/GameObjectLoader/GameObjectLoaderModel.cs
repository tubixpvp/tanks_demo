using Core.GameObjects;
using Core.Model;
using CoreModels.Dispatcher;
using CoreModels.Resources;
using GameResources;
using Network.Session;
using OSGI.Services;
using Utils;

namespace CoreModels.GameObjectLoader;

[ModelEntity(typeof(GameObjectLoaderEntity))]
[Model(ServerOnly = true)]
internal class GameObjectLoaderModel(long id) : ModelBase<object>(id), ObjectClientListener.Attached
{
    [InjectService]
    private static ClientResourcesService ClientResourcesService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    public void ObjectAttached(NetworkSession session)
    {
        GameObject gameObject = Context.Object;
        
        List<string> requiredResources = new List<string>();

        gameObject.Events<IResourceRequire>().CollectGameResources(requiredResources);

        ResourceInfo[] uniqueResources = requiredResources
            .Distinct()
            .Select(ResourceRegistry.GetResourceInfo)
            .ToArray();

        if (!uniqueResources.Any())
        {
            OnResourcesLoaded(gameObject, session);
            return;
        }

        //TODO: cancel object load ability
        CancellableFunction resourcesLoadCancelToken = new CancellableFunction(
            () => OnResourcesLoaded(gameObject, session), new SimpleCancelToken());

        ClientResourcesService.LoadResources(session, uniqueResources, resourcesLoadCancelToken.Call);
    }

    private void OnResourcesLoaded(GameObject gameObject, NetworkSession session)
    {
        IDispatcher dispatcher = gameObject.Space.GetRootObject().Adapt<IDispatcher>();
        dispatcher.LoadEntities([gameObject], [session]);
    }
}