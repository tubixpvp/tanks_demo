using Config;
using Core.GameObjects;
using Core.Model.Registry;
using Core.Spaces;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using OSGI.Services;
using Platform.Models.Core.Child;
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

    private GameObject[] InitObjects(ObjectDataJson[] objectsData, GameObjectsStorage objectsStorage, GameObject? parentObject)
    {
        return objectsData.Select(
            objectData =>
            {
                
                object[] entities = ConvertEntities(objectData.Entities);

                ParentEntity? parentEntity = null;
                if (objectData.Children.Length > 0)
                {
                    entities = entities.Append(parentEntity = new ParentEntity()).ToArray();
                }

                if (parentObject != null)
                {
                    entities = entities.Append(new ChildModelEntity()
                    {
                        Parent = parentObject
                    }).ToArray();
                }

                GameObject gameObject = objectsStorage.CreateObject(objectData.Name, entities);
                gameObject.Params.AutoAttach = objectData.AutoAttach;

                GameObject[] children = InitObjects(objectData.Children, objectsStorage, parentObject);

                if (parentEntity != null)
                {
                    foreach (GameObject childObject in children)
                    {
                        parentEntity.Children.TryAdd(childObject.Id, childObject);
                    }
                }

                gameObject.Load();

                return gameObject;
                
            }).ToArray();
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