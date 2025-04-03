using Config;
using Core.Space;
using Newtonsoft.Json;
using OSGI.Services;

namespace SpacesCommons;

[Service]
internal class SpacesActivatorService : IOSGiInitListener
{
    [InjectService]
    private static SpaceRegistry SpaceRegistry;
    
    public void OnOSGiInited()
    {
        SpaceConfigJson[] configs = [
            ServerResources.GetConfig<SpaceConfigJson>("entrance_space.json")
        ];

        foreach (SpaceConfigJson config in configs)
        {
            Space space = SpaceRegistry.CreateSpace(config.Id, config.Name);
            
            //
        }
    }

    class SpaceConfigJson
    {
        [JsonProperty("id")]
        public long Id;

        [JsonProperty("name")]
        public string Name;
    }
}