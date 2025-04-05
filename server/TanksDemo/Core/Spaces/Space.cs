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


    private readonly Dictionary<long, GameObject> _gameObjectsById = new();
    private readonly Dictionary<string, GameObject> _gameObjectsByName = new();

    private readonly List<NetworkSession> _sessions = new();

    private readonly ILogger _logger;

    internal Space(long id, string name)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        Id = id;
        Name = name;
        
        CreateRootObject();
    }

    private void CreateRootObject()
    {
        Type dispatcherEntityType = ModelRegistry.GetEntityTypeByName("DispatcherEntity");
        object dispatcherEntityInstance = Activator.CreateInstance(dispatcherEntityType)!;
        
        CreateObject("root", [dispatcherEntityInstance], null, 0);
    }
    public GameObject GetRootObject()
    {
        return GetObject(0)!;
    }

    public GameObject CreateObject(string name, IEnumerable<object>? entities, long? parentId, long? objectId = null)
    {
        lock (_gameObjectsByName)
        {
            if (_gameObjectsByName.ContainsKey(name))
            {
                throw new Exception("ClientObject with this name already exists: " + name);
            }
            
            lock (_gameObjectsById)
            {
                long id;
                if (objectId == null)
                {
                    do
                    {
                        id = Random.NextInt64(int.MinValue, int.MaxValue);
                    } while (_gameObjectsById.ContainsKey(id));
                }
                else
                {
                    id = (long)objectId;
                }

                GameObject? parentObject = parentId != null ? GetObject((long)parentId) : null;

                IEnumerable<object> systemEntities = [CreateObjectLoaderEntity()];
                
                GameObject gameObject = new GameObject(id, parentObject, name, this, entities?.Concat(systemEntities) ?? systemEntities);
                
                _gameObjectsById.Add(id, gameObject);
                _gameObjectsByName.Add(name, gameObject);

                return gameObject;
            }
        }
    }

    private object CreateObjectLoaderEntity()
    {
        Type objectLoaderEntity = ModelRegistry.GetEntityTypeByName("GameObjectLoaderEntity");
        return Activator.CreateInstance(objectLoaderEntity)!;
    }

    public GameObject? GetObject(long id)
    {
        lock (_gameObjectsById)
        {
            return _gameObjectsById.GetValueOrDefault(id);
        }
    }

    public void AddSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Add(spaceSession);
        }

        lock (_gameObjectsById)
        {
            foreach (GameObject gameObject in _gameObjectsById.Values)
            {
                gameObject.Attach(spaceSession);
            }
        }
    }

    public void RemoveSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Remove(spaceSession);
        }
        
    }
    
}