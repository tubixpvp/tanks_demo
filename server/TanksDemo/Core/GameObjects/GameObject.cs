using System.Collections.Concurrent;
using Core.GameObjects.Adapts;
using Core.Model;
using Core.Model.Registry;
using Core.Spaces;
using Network.Session;
using OSGI.Services;

namespace Core.GameObjects;

public class GameObject
{
    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    public long Id { get; }
    public string Name { get; }
    
    public Space Space { get; }
    
    public GameObjectParams Params { get; }

    public List<long> ModelsIds { get; }
    

    private readonly Dictionary<Type, object> _entities = new();

    private readonly ConcurrentDictionary<Type, object> _eventProxies = new();
    private readonly ConcurrentDictionary<Type, object> _adaptProxies = new();

    private readonly ConcurrentDictionary<Type, object> _runtimeData = new();
    private readonly ConcurrentDictionary<long, ModelInitParams> _modelsClientInitParams = new();

    private bool _loaded;
    
    internal GameObject(long id,
        string name, 
        Space space, 
        IEnumerable<object> modelEntities)
    {
        Id = id;
        Name = name;
        Space = space;
        Params = new();
        ModelsIds = new List<long>();
        InitFromEntities(modelEntities);
    }

    private void InitFromEntities(IEnumerable<object> objectEntities)
    {
        foreach (object entity in objectEntities)
        {
            Type entityType = entity.GetType();

            IModel model = ModelRegistry.GetModelByEntityType(entityType);

            _entities.Add(entityType, entity);

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
        Space.AttachObject(session, this);
    }
    public void Detach(NetworkSession session)
    {
        Space.DetachObject(session, this);
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
        return TryAdapt<T>() ??
               throw new Exception("Model that implements interface is not found: " + typeof(T).FullName);
    }
    public T? TryAdapt<T>() where T : class
    {
        Type type = typeof(T);

        if (_adaptProxies.TryGetValue(type, out object? storedProxy))
        {
            return (T)storedProxy;
        }
        
        long? modelId = ModelsIds.FirstOrDefault(id => ModelRegistry.GetModelById(id) is T);

        if (modelId == 0 || modelId == null)
            return null;
        
        IModel model = ModelRegistry.GetModelById(modelId.Value);

        T proxy = GameObjectAdaptProxy.Create<T>(this, [(T)model]);
        
        _adaptProxies.TryAdd(type, proxy);

        return proxy;
    }


    public Action GetFunctionWrapper(Action func, NetworkSession? session = null)
    {
        return () =>
        {
            if (!_loaded)
                return;
            ModelContext.RunLocked(() =>
            {
                ModelGlobals.PutContext(new ModelContext(this, session));

                func();
                
                ModelGlobals.PopContext();
            });
        };
    }
    
    
    public void PutData(Type key, object data) => _runtimeData[key] = data;
    public T? GetData<T>(Type key) => (T?)_runtimeData.GetValueOrDefault(key);
    public T? ClearData<T>(Type key) => _runtimeData.TryRemove(key, out object? data) ? (T?)data : default;

    public void PutClientInitParams(long modelId, ModelInitParams initParams) => _modelsClientInitParams[modelId] = initParams;
    public ModelInitParams? GetClientInitParams(long modelId) => _modelsClientInitParams.GetValueOrDefault(modelId);

    public T GetModelEntity<T>() => (T)_entities[typeof(T)];
    
    public override string ToString()
    {
        return $"{nameof(GameObject)}(name={Name}, id={Id})";
    }
    
}