using Core.GameObjects;
using Core.Models.Dispatcher;
using Logging;
using Network.Session;
using OSGI.Services;

namespace Core.Spaces;

public class Space
{
    [InjectService]
    private static LoggerService LoggerService;


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
        CreateObject("root", [new DispatcherEntity()], null, 0);
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

                GameObject gameObject = new GameObject(id, parentObject, name, this, entities ?? []);
                
                _gameObjectsById.Add(id, gameObject);
                _gameObjectsByName.Add(name, gameObject);

                return gameObject;
            }
        }
    }

    public GameObject GetObject(long id)
    {
        lock (_gameObjectsById)
        {
            return _gameObjectsById[id];
        }
    }

    public void AddSession(NetworkSession spaceSession)
    {
        lock (_sessions)
        {
            _sessions.Add(spaceSession);
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