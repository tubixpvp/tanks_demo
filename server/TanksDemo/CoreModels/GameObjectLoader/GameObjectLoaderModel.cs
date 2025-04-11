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
internal class GameObjectLoaderModel(long id) : ModelBase<object>(id), ObjectDeployListener.Deploy
{
    [InjectService]
    private static ClientResourcesService ClientResourcesService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    public void DeployObject(NetworkSession session, SimpleCancelToken cancelToken)
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

        CancellableFunction resourcesLoadCancelToken = new CancellableFunction(
            () => OnResourcesLoaded(gameObject, session), cancelToken);

        ClientResourcesService.LoadResources(session, uniqueResources, resourcesLoadCancelToken.Call);
    }

    private void OnResourcesLoaded(GameObject gameObject, NetworkSession session)
    {
        IDispatcher dispatcher = gameObject.Space.GetRootObject().Adapt<IDispatcher>();
        dispatcher.LoadEntities([gameObject], [session]);
    }
}