using System.Reflection;
using Logging;
using OSGI.Services;
using Utils;

namespace Core.Model.Registry;

[Service]
public class ModelRegistry
{
    [InjectService]
    private static LoggerService LoggerService;
    
    
    private readonly Dictionary<long, IModel> _idToModel = new();
    private readonly Dictionary<Type, List<IModel>> _entityToModels = new();

    private ILogger _logger;

    public void Init()
    {
        _logger = LoggerService.GetLogger(typeof(ModelRegistry));
        
        Type[] modelsTypes = AttributesUtil.GetTypesWithAttribute(typeof(ModelAttribute));
        
        Console.WriteLine("models: " + string.Join(',',modelsTypes.Select(type => type.Name)));

        foreach (Type modelType in modelsTypes)
        {
            AddModel(modelType);
        }
    }
    
    private void AddModel(Type modelType)
    {
        IModel model = (Activator.CreateInstance(modelType) as IModel)!;
        
        _idToModel.Add(model.Id, model);

        foreach (ModelEntityAttribute entityAttribute in modelType
                     .GetCustomAttributes<ModelEntityAttribute>(false))
        {
            if (!_entityToModels.TryGetValue(entityAttribute.EntityType, out var models))
            {
                _entityToModels.Add(entityAttribute.EntityType, models = new List<IModel>());
            }
            models.Add(model);
        }
        
        _logger.Log(LogLevel.Debug, "Registered model " + modelType.Name);
    }
    
    public IModel GetModelById(long id) => _idToModel[id];

    public IModel[] GetAllModels() => _idToModel.Values.ToArray();
    
}