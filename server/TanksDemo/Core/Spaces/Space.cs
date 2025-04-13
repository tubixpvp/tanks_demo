using Core.GameObjects;
using Core.Model.Registry;
using Logging;
using Network.Session;
using OSGI.Services;
using Utils;

namespace Core.Spaces;

public class Space
{
    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    public long Id { get; }
    public string Name { get; }

    public GameObjectsStorage ObjectsStorage { get; }
    public IGameObjectTemplates TemplatesStorage { get; }

    private const string SessionDataKey = "SessionSpaceData";

    private readonly List<NetworkSession> _sessions = new();

    private readonly ILogger _logger;

    internal Space(long id, string name, IGameObjectTemplates templatesStorageImpl)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        Id = id;
        Name = name;

        ObjectsStorage = new GameObjectsStorage(this);
        TemplatesStorage = templatesStorageImpl;
        
        CreateRootObject();
    }

    private void CreateRootObject()
    {
        Type dispatcherEntityType = ModelRegistry.GetEntityTypeByName("DispatcherEntity");
        object dispatcherEntityInstance = Activator.CreateInstance(dispatcherEntityType)!;

        ObjectsStorage.CreateObject("root", [dispatcherEntityInstance], 0).Params.AutoAttach = false;
    }
    public GameObject GetRootObject()
    {
        return ObjectsStorage.GetObject(0)!;
    }

    public void AddSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Add(spaceSession);
        }
        
        ObjectsStorage.ForeachInObjects(gameObject =>
        {
            if (!gameObject.Params.AutoAttach)
                return;
            AttachObject(spaceSession, gameObject);
        });
    }

    public void RemoveSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Remove(spaceSession);
        }

        SessionSpaceData sessionData = GetSessionData(spaceSession);

        GameObject[] deployingObjects;
        GameObject[] attachedObjects;
        lock (sessionData)
        {
            deployingObjects = sessionData.DeployingObjects.Keys.ToArray();
            attachedObjects = sessionData.AttachedObjects.ToArray();
        }

        foreach (GameObject deployingObject in deployingObjects)
        {
            CancelObjectDeploy(spaceSession, deployingObject);
        }
        
        foreach (GameObject attachedObject in attachedObjects)
        {
            DetachObject(spaceSession, attachedObject);
        }

        spaceSession.DeleteAttribute(SessionDataKey);
    }

    internal void DestroyObject(GameObject gameObject)
    {
        lock (_sessions)
        {
            foreach (NetworkSession session in _sessions)
            {
                CancelObjectDeploy(session, gameObject);
                DetachObject(session, gameObject);
            }
        }
        
        gameObject.Events<ObjectListener.Unload>().ObjectUnloaded();

        ObjectsStorage.DeleteObject(gameObject.Name);

        _logger.Log(LogLevel.Debug,
            "GameObject destroyed: " + gameObject);
    }

    public void AttachObjectToAll(GameObject gameObject)
    {
        lock (_sessions)
        {
            foreach (NetworkSession session in _sessions)
            {
                SessionSpaceData data = GetSessionData(session);

                if (!data.AttachedObjects.Contains(gameObject))
                {
                    AttachObject(session, gameObject);
                }
            }
        }
    }
    
    internal void AttachObject(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);

        SimpleCancelToken deployCancelToken = new();
        
        lock (data)
        {
            if (data.AttachedObjects.Contains(gameObject))
            {
                throw new Exception("Object is already attached: " + gameObject);
            }
            
            data.AttachedObjects.Add(gameObject);

            data.DeployingObjects.Add(gameObject, deployCancelToken);
        }

        gameObject.Events<ObjectAttachListener.Attached>().ObjectAttached(session);
        gameObject.Events<ObjectDeployListener.Deploy>().DeployObject(session, deployCancelToken);
    }
    public void OnObjectDeployed(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);
        lock (data)
        {
            data.DeployingObjects.Remove(gameObject);
            data.DeployedObjects.Add(gameObject);
        }
        gameObject.Events<ObjectDeployListener.Deployed>().ObjectDeployed(session);
    }
    public void OnObjectUndeployed(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);
        lock (data)
        {
            data.DeployedObjects.Remove(gameObject);
        }
    }
    
    private void CancelObjectDeploy(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);
        SimpleCancelToken? deployCancelToken;
        lock (data)
        {
            data.DeployingObjects.Remove(gameObject, out deployCancelToken);
        }
        deployCancelToken?.Cancel();
    }
    internal void DetachObject(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);
        bool removed;
        lock (data)
        {
            removed = data.AttachedObjects.Remove(gameObject);
            
            data.DeployingObjects.Remove(gameObject);
        }
        if (removed)
        {
            gameObject.Events<ObjectAttachListener.Detached>().ObjectDetached(session);
        }
    }
    public bool IsObjectDeployed(NetworkSession session, GameObject gameObject)
    {
        SessionSpaceData data = GetSessionData(session);
        lock (data)
        {
            return data.DeployedObjects.Contains(gameObject);
        }
    }

    public IEnumerable<NetworkSession> GetDeployedSessions(GameObject gameObject)
    {
        lock (_sessions)
        {
            return _sessions.Where(session => IsObjectDeployed(session, gameObject));
        }
    }

    private SessionSpaceData GetSessionData(NetworkSession session)
    {
        SessionSpaceData? data = session.GetAttribute<SessionSpaceData>(SessionDataKey);
        if (data == null)
        {
            data = new SessionSpaceData();
            session.SetAttribute(SessionDataKey, data);
        }
        return data;
    }
    
}