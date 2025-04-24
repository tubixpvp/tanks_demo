using Config;
using Core.Model.Registry;
using Core.Spaces;
using Logging;
using Newtonsoft.Json;
using OSGI.Services;
using SpacesCommons.Templates;

namespace SpacesCommons;

[Service]
public class SpacesActivatorService
{
    [InjectService]
    private static SpaceRegistry SpaceRegistry;

    [InjectService]
    private static ModelRegistry ModelRegistry;

    [InjectService]
    private static LoggerService LoggerService;
    
    public void Init()
    {
        ILogger logger = LoggerService.GetLogger(GetType());
        
        SpaceConfigJson[] configs = ServerResources.GetConfigsInPath<SpaceConfigJson>("Spaces/");

        foreach (SpaceConfigJson config in configs)
        {
            logger.Log(LogLevel.Info, "Creating space " + config.Name);
            
            GameObjectTemplatesStorage templates = new GameObjectTemplatesStorage(config.Templates);

            Space space = SpaceRegistry.CreateSpace(config.Name, templates);

            templates.InitObjects(config.Objects, space.ObjectsStorage, null);
        }
    }

    class SpaceConfigJson
    {
        [JsonProperty("name")]
        public string Name;

        [JsonProperty("objects")]
        public GameObjectTemplate[] Objects;
        
        [JsonProperty("templates")]
        public GameObjectTemplate[] Templates;
    }
    
}