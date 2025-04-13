using Core.GameObjects;
using Core.Model;
using CoreModels.Dispatcher;
using CoreModels.Resources;
using GameResources;
using Logging;
using Network.Session;
using OSGI.Services;
using Platform.Models.Core.Child;
using Utils;

namespace CoreModels.GameObjectLoader;

[ModelEntity(typeof(GameObjectLoaderEntity))]
[Model(ServerOnly = true)]
internal class GameObjectLoaderModel(long id) : ModelBase<object>(id), ObjectDeployListener.Deploy, IGameObjectLoader, ObjectAttachListener.Detached
{
    [InjectService]
    private static ClientResourcesService ClientResourcesService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    
    private const string DeployListenersKey = "ObjectDeployListeners";
    
    
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
            OnResourcesLoaded(gameObject, session, cancelToken);
            return;
        }

        CancellableFunction resourcesLoadCancelToken = new CancellableFunction(
            () => OnResourcesLoaded(gameObject, session, cancelToken), cancelToken);

        ClientResourcesService.LoadResources(session, uniqueResources, resourcesLoadCancelToken.Call);
    }

    private void OnResourcesLoaded(GameObject gameObject, NetworkSession session, SimpleCancelToken cancelToken)
    {
        IChild? child = gameObject.TryAdapt<IChild>();
        if (child != null)
        {
            GameObject parentObject = child.GetParent();
            if (parentObject.Params.AutoAttach &&
                !parentObject.Space.IsObjectDeployed(session, parentObject))
            {
                //parent must be loaded first

                CancellableFunction callback = new CancellableFunction(
                    () => LoadEntity(gameObject, session), cancelToken);

                parentObject.Adapt<IGameObjectLoader>().AddDeployListener(session, callback.Call);

                GetLogger().Log(LogLevel.Warn, "Waiting for parent: " + parentObject);
                
                return;
            }
        }

        LoadEntity(gameObject, session);
    }

    private void LoadEntity(GameObject gameObject, NetworkSession session)
    {
        IDispatcher dispatcher = gameObject.Space.GetRootObject().Adapt<IDispatcher>();
        dispatcher.LoadEntities([gameObject], [session]);
        
        gameObject.Space.OnObjectDeployed(session, gameObject);

        List<Action>? listeners = GetDeployListeners(session, gameObject, false);
        if (listeners != null)
        {
            GetLogger().Log(LogLevel.Warn, "Has listeners, calling. From " + gameObject);
            foreach (Action callback in listeners)
            {
                callback();
            }
            listeners.Clear();
        }
    }


    public void AddDeployListener(NetworkSession session, Action callback)
    {
        GetDeployListeners(session, Context.Object, true)!.Add(callback);
    }

    private List<Action>? GetDeployListeners(NetworkSession session, GameObject gameObject, bool createIfNotExists)
    {
        GameObjectDeployListeners? listenersObj = session.GetAttribute<GameObjectDeployListeners>(DeployListenersKey);
        if (listenersObj == null)
        {
            if (!createIfNotExists)
                return null;
            session.SetAttribute(DeployListenersKey, listenersObj = new GameObjectDeployListeners());
        }
        List<Action>? callbacks = listenersObj.Listeners.GetValueOrDefault(gameObject);
        if (callbacks == null)
        {
            if (!createIfNotExists)
                return null;
            listenersObj.Listeners.TryAdd(gameObject, callbacks = new List<Action>());
        }
        return callbacks;
    }

    public void ObjectDetached(NetworkSession session)
    {
        GameObject gameObject = Context.Object;
        
        if (Context.Space.IsObjectDeployed(session, gameObject))
        {
            if (session.Socket.Connected)
            {
                Context.Space.GetRootObject().Adapt<IDispatcher>().UnloadEntities([gameObject], [session]);
            }

            Context.Space.OnObjectUndeployed(session, gameObject);
        }
    }
}