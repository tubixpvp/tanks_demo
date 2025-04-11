using Core.GameObjects;
using Core.Model.Registry;
using Logging;
using Network.Session;
using OSGI.Services;

namespace Core.Spaces;

public class Space
{
    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static ModelRegistry ModelRegistry;


    private static readonly Random Random = new();
    
    public long Id { get; }
    public string Name { get; }

    public GameObjectsStorage ObjectsStorage { get; }
    

    private readonly List<NetworkSession> _sessions = new();

    private readonly ILogger _logger;

    internal Space(long id, string name)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        Id = id;
        Name = name;

        ObjectsStorage = new GameObjectsStorage(this);
        
        CreateRootObject();
    }

    private void CreateRootObject()
    {
        Type dispatcherEntityType = ModelRegistry.GetEntityTypeByName("DispatcherEntity");
        object dispatcherEntityInstance = Activator.CreateInstance(dispatcherEntityType)!;
        
        ObjectsStorage.CreateObject("root", [dispatcherEntityInstance], null, 0);
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
        
        ObjectsStorage.ForeachInObjects(gameObject => gameObject.Attach(spaceSession));
    }

    public void RemoveSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Remove(spaceSession);
        }
        
        ObjectsStorage.ForeachInObjects(gameObject => gameObject.Detach(spaceSession));
    }
    
}