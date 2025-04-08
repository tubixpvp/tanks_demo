using System.Collections.Concurrent;
using Core.GameObjects.Adapts;
using Core.Model;
using Core.Model.Registry;
using Core.Spaces;
using Network.Session;
using OSGI.Services;
using Utils;

namespace Core.GameObjects;

public class GameObject
{
    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    public long Id { get; }
    public string Name { get; }
    
    public Space Space { get; }
    public GameObject? Parent { get; }
    
    public GameObjectParams Params { get; }

    public List<long> ModelsIds { get; }
    

    private readonly Dictionary<long, List<object>> _entities = new();

    private readonly ConcurrentDictionary<Type, object> _eventProxies = new();
    private readonly ConcurrentDictionary<Type, object> _adaptProxies = new();

    private readonly ConcurrentDictionary<Type, object> _runtimeData = new();
    private readonly ConcurrentDictionary<long, ModelInitParams> _modelsClientInitParams = new();

    private bool _loaded;
    
    internal GameObject(long id, 
        GameObject? parent, 
        string name, 
        Space space, 
        IEnumerable<object> modelEntities)
    {
        Id = id;
        Name = name;
        Parent = parent;
        Space = space;
        Params = new();
        ModelsIds = new List<long>();
        InitFromEntities(modelEntities);
    }

    private void InitFromEntities(IEnumerable<object> objectEntities)
    {
        foreach (object entity in objectEntities)
        {
            IModel model = ModelRegistry.GetModelByEntityType(entity.GetType());

            if (!_entities.TryGetValue(model.Id, out var entities))
            {
                _entities.Add(model.Id, entities = new List<object>());
            }
            
            entities.Add(entity);

            if (!ModelsIds.Contains(model.Id))
            {
                ModelsIds.Add(model.Id);
            }
        }
    }

    public void Load()
    {
        if (_loaded)
            throw new Exception("ClientObject is already loaded: " + Name);
        _loaded = true;
        
        Events<ObjectListener.Load>().ObjectLoaded();
    }

    public void UnloadAndDestroy()
    {
    }


    public void Attach(NetworkSession session)
    {
        //

        Events<ObjectClientListener.Attached>().ObjectAttached(session);
    }
    public bool IsAttached(NetworkSession session)
    {
        return true;
    }
    
    public T Events<T>() where T : class
    {
        Type type = typeof(T);

        if (_eventProxies.TryGetValue(type, out object? storedProxy))
        {
            return (T)storedProxy;
        }

        T proxy = GameObjectAdaptProxy.Create(this,
            ModelsIds.Select(modelId => ModelRegistry.GetModelById(modelId))
            .OfType<T>().ToArray());
        
        _eventProxies.TryAdd(type, proxy);

        return proxy;
    }

    public T Adapt<T>() where T : class
    {
        Type type = typeof(T);

        if (_adaptProxies.TryGetValue(type, out object? storedProxy))
        {
            return (T)storedProxy;
        }
        
        long? modelId = ModelsIds.FirstOrDefault(id => ModelRegistry.GetModelById(id) is T);

        if (modelId == 0 || modelId == null)
            throw new Exception("Model that implements interface is not found: " +type.FullName);
        
        IModel model = ModelRegistry.GetModelById(modelId.Value);

        T proxy = GameObjectAdaptProxy.Create<T>(this, [(T)model]);
        
        _adaptProxies.TryAdd(type, proxy);

        return proxy;
    }
    
    
    public void PutData(Type key, object data) => _runtimeData[key] = data;
    public T? GetData<T>(Type key) => (T?)_runtimeData.GetValueOrDefault(key);
    public T? ClearData<T>(Type key) => _runtimeData.TryRemove(key, out object? data) ? (T?)data : default;

    public void PutClientInitParams(long modelId, ModelInitParams initParams) => _modelsClientInitParams[modelId] = initParams;
    public ModelInitParams? GetClientInitParams(long modelId) => _modelsClientInitParams.GetValueOrDefault(modelId);

    public T GetModelEntity<T>(long modelId) => (T)_entities[modelId].First(entity => entity is T);
    
    public override string ToString()
    {
        return $"{nameof(GameObject)}(name={Name}, id={Id})";
    }
    
}