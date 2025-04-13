using Core.GameObjects;
using Core.Model.Registry;
using OSGI.Services;

namespace Core.Spaces;

public class GameObjectsStorage(Space space)
{
    [InjectService]
    private static ModelRegistry ModelRegistry;


    private static readonly Random Random = new();
    
    
    private readonly Dictionary<long, GameObject> _gameObjectsById = new();
    private readonly Dictionary<string, GameObject> _gameObjectsByName = new();
    
    
    public GameObject CreateObject(string name, IEnumerable<object>? entities, long? objectId = null)
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

                IEnumerable<object> systemEntities = [CreateObjectLoaderEntity()];
                
                GameObject gameObject = new GameObject(id, name, space, entities?.Concat(systemEntities) ?? systemEntities);
                
                _gameObjectsById.Add(id, gameObject);
                _gameObjectsByName.Add(name, gameObject);

                return gameObject;
            }
        }
    }

    public void DeleteObject(string name)
    {
        lock (_gameObjectsByName)
        {
            if (!_gameObjectsByName.Remove(name, out GameObject? gameObject))
                return;
            
            _gameObjectsById.Remove(gameObject.Id);
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

    public GameObject? GetObject(string name)
    {
        lock (_gameObjectsByName)
        {
            return _gameObjectsByName.GetValueOrDefault(name);
        }
    }

    public void ForeachInObjects(Action<GameObject> callback)
    {
        lock (_gameObjectsById)
        {
            foreach (GameObject gameObject in _gameObjectsById.Values)
            {
                callback(gameObject);
            }
        }
    }

    public GameObject[] GetObjects()
    {
        lock (_gameObjectsById)
        {
            return _gameObjectsById.Values.ToArray();
        }
    }
    
}