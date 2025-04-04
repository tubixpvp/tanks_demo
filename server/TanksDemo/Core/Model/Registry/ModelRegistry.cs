using System.Reflection;
using System.Runtime.CompilerServices;
using Config;
using Core.Model.Communication;
using Logging;
using Newtonsoft.Json;
using OSGI.Services;
using Utils;

namespace Core.Model.Registry;

[Service]
public class ModelRegistry
{
    [InjectService]
    private static LoggerService LoggerService;


    private static readonly Random Random = new();
    
    
    private readonly Dictionary<long, IModel> _idToModel = new();
    
    private readonly Dictionary<Type, IModel> _entityToModel = new();

    private readonly Dictionary<string, Type> _entityTypeByName = new();

    private readonly Dictionary<MethodInfo, long> _methodsIds = new();

    
    private readonly Dictionary<long, (long modelId, MethodInfo method, bool isAsync)> _serverMethods = new();
    

    private readonly Type[] _modelsTypes;
    
    private ILogger _logger;


    public ModelRegistry()
    {
        ModelGlobals.ModelRegistry = this;
        
        string modelsConfigPath = ServerLaunchParams.GetLaunchParams().GetString("models") ?? throw new Exception("Models config path is not provided");
        modelsConfigPath = Path.GetFullPath(modelsConfigPath);
        
        _modelsTypes = AttributesUtil.GetTypesWithAttribute(typeof(ModelAttribute));
        
        Console.WriteLine("Models: " + string.Join(',',_modelsTypes.Select(type => type.Name)));
        
        CollectEntities();

        
        ModelsConfig config;
        if (File.Exists(modelsConfigPath))
            config = JsonConvert.DeserializeObject<ModelsConfig>(File.ReadAllText(modelsConfigPath))!;
        else
            config = new ModelsConfig()
            {
                Models = new Dictionary<string, ModelConfig>()
            };

        foreach (Type modelType in _modelsTypes)
        {
            AddModel(modelType, config);
        }
        
        File.WriteAllText(modelsConfigPath, JsonConvert.SerializeObject(config, Formatting.Indented));
    }

    class ModelsConfig
    {
        public Dictionary<string, ModelConfig> Models;
    }
    class ModelConfig
    {
        public long Id;
        public Dictionary<string, long>? ClientMethods;
        public Dictionary<string, long>? ServerMethods;
    }

    private void CollectEntities()
    {
        foreach (Type modelType in _modelsTypes)
        {
            foreach (ModelEntityAttribute entityAttribute in modelType
                         .GetCustomAttributes<ModelEntityAttribute>(false))
            {
                _entityTypeByName.Add(entityAttribute.EntityType.Name, entityAttribute.EntityType);
            }
        }
    }
    
    public void Init()
    {
        _logger = LoggerService.GetLogger(typeof(ModelRegistry));
    }
    
    private void AddModel(Type modelType, ModelsConfig modelsConfig)
    {
        //get model cache
        if (!modelsConfig.Models.TryGetValue(modelType.Name, out ModelConfig? modelConfig))
        {
            modelsConfig.Models.Add(modelType.Name, modelConfig = new ModelConfig()
            {
                Id = Random.NextInt64(long.MinValue,long.MaxValue)
            });
        }
        modelConfig.ClientMethods ??= new Dictionary<string, long>();
        modelConfig.ServerMethods ??= new Dictionary<string, long>();
        
        
        long modelId = modelConfig.Id;
        
        //init server methods:
        MethodInfo[] serverMethods = ModelUtils.GetServerInterfaceMethods(modelType);
        foreach (MethodInfo methodInfo in serverMethods)
        {
            string methodName = methodInfo.Name;

            NetworkMethodAttribute netMethodAttribute = methodInfo.GetCustomAttribute<NetworkMethodAttribute>()!;

            long methodId;
            if (netMethodAttribute.MethodId != null)
            {
                methodId = netMethodAttribute.MethodId.Value;
            }
            else if (!modelConfig.ServerMethods.TryGetValue(methodName, out methodId))
            {
                methodId = Random.NextInt64(long.MinValue, long.MaxValue);
                modelConfig.ServerMethods.Add(methodName, methodId);
            }

            _methodsIds.Add(methodInfo, methodId);

            bool isAsync = methodInfo.GetCustomAttribute<AsyncStateMachineAttribute>() != null;
            
            _serverMethods.Add(methodId, (modelId, methodInfo, isAsync));
        }
        
        //init model & entities
        IModel model = (Activator.CreateInstance(modelType, new object[] {modelId}) as IModel)!;
        
        _idToModel.Add(model.Id, model);

        foreach (ModelEntityAttribute entityAttribute in modelType
                     .GetCustomAttributes<ModelEntityAttribute>(false))
        {
            _entityToModel.Add(entityAttribute.EntityType, model);
        }
        
        //init client methods:
        Type clientInterfaceType = model.GetClientInterfaceType();
        
        MethodInfo[] clientMethods = clientInterfaceType.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
        clientMethods = clientMethods.Where(method => 
            method.Name != ModelUtils.InitObjectFunc
            && method.DeclaringType != typeof(object)).ToArray();

        foreach (MethodInfo methodInfo in clientMethods)
        {
            string methodName = methodInfo.Name;

            NetworkMethodAttribute? netMethodAttribute = methodInfo.GetCustomAttribute<NetworkMethodAttribute>();

            long methodId;
            if (netMethodAttribute != null && netMethodAttribute.MethodId != null)
            {
                methodId = netMethodAttribute.MethodId.Value;
            }
            else if (!modelConfig.ClientMethods.TryGetValue(methodName, out methodId))
            {
                methodId = Random.NextInt64(long.MinValue, long.MaxValue);
                modelConfig.ClientMethods.Add(methodName, methodId);
            }
            
            _methodsIds.Add(methodInfo, methodId);
        }

        Console.WriteLine("Registered model " + modelType.Name + " with id: " + model.Id);
    }
    
    internal IModel GetModelById(long id) => _idToModel[id];
    internal IModel GetModelByEntityType(Type entityType) => _entityToModel.GetValueOrDefault(entityType)
                                                             ?? throw new Exception("Entity not found: " + entityType.Name);
    
    public Type GetEntityTypeByName(string name) => _entityTypeByName.GetValueOrDefault(name) 
                                                    ?? throw new Exception("Entity not found: " + name);

    public IModel[] GetAllModels() => _idToModel.Values.ToArray();
    
    public long GetMethodId(MethodInfo methodInfo) => _methodsIds[methodInfo];

    public (MethodInfo methodInfo, IModel model, bool isAsync) GetModelAndMethodById(long methodId)
    {
        (long modelId, MethodInfo methodInfo, bool isAsync) = _serverMethods[methodId];
        IModel model = GetModelById(modelId);
        return (methodInfo, model, isAsync);
    }
    
}