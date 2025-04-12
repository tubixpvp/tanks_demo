using Config;
using Core.Model.Registry;
using Core.Spaces;
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
    
    public void Init()
    {
        SpaceConfigJson[] configs = new []
        {
            "entrance_space.json", "battle_space_template.json", "lobby_space.json"
        }.Select(ServerResources.GetConfig<SpaceConfigJson>).ToArray();

        foreach (SpaceConfigJson config in configs)
        {
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