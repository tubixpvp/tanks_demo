using Config;
using Core.GameObjects;
using Core.Model.Registry;
using Core.Spaces;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using OSGI.Services;
using Platform.Models.Core.Parent;

namespace SpacesCommons;

[Service]
public class SpacesActivatorService
{
    [InjectService]
    private static SpaceRegistry SpaceRegistry;

    [InjectService]
    private static ModelRegistry ModelRegistry;

    private static readonly Random Random = new();
    
    public void Init()
    {
        SpaceConfigJson[] configs = [
            ServerResources.GetConfig<SpaceConfigJson>("entrance_space.json"),
            ServerResources.GetConfig<SpaceConfigJson>("lobby_space.json")
        ];

        foreach (SpaceConfigJson config in configs)
        {
            Space space = SpaceRegistry.CreateSpace(Random.NextInt64(long.MinValue,long.MaxValue), config.Name);

            InitObjects(config.Objects, space.ObjectsStorage, null);
        }
    }

    private void InitObjects(ObjectDataJson[] objectsData, GameObjectsStorage objectsStorage, GameObject? parentObject)
    {
        foreach (ObjectDataJson objectData in objectsData)
        {
            object[] entities = ConvertEntities(objectData.Entities);

            if (objectData.Children.Length > 0)
            {
                entities = entities.Append(new ParentEntity()).ToArray();
            }
            
            GameObject gameObject = objectsStorage.CreateObject(objectData.Name, entities);
            gameObject.Params.AutoAttach = objectData.AutoAttach;

            InitObjects(objectData.Children, objectsStorage, parentObject);
                
            gameObject.Load();
        }
    }

    private object[] ConvertEntities(Dictionary<string, JObject> entitiesJson)
    {
        return entitiesJson.Select(entry =>
        {
            Type entityType = ModelRegistry.GetEntityTypeByName(entry.Key);

            return entry.Value.ToObject(entityType)!;
        }).ToArray();
    }

    class SpaceConfigJson
    {
        [JsonProperty("name")]
        public string Name;

        [JsonProperty("objects")]
        public ObjectDataJson[] Objects;
    }

    class ObjectDataJson
    {
        [JsonProperty("name")]
        public string Name;

        [JsonProperty("entities")]
        public Dictionary<string, JObject> Entities;

        [JsonProperty("children")]
        public ObjectDataJson[] Children;

        [JsonProperty("attach")]
        public bool AutoAttach;
    }
}