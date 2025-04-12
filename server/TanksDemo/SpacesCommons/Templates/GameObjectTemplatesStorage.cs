using Core.GameObjects;
using Core.Model.Registry;
using Core.Spaces;
using Newtonsoft.Json.Linq;
using OSGI.Services;
using Platform.Models.Core.Child;
using Platform.Models.Core.Parent;

namespace SpacesCommons.Templates;

internal class GameObjectTemplatesStorage : IGameObjectTemplates
{ 
    [InjectService]
    private static ModelRegistry ModelRegistry;


    private readonly Dictionary<string, GameObjectTemplate> _templates;


    public GameObjectTemplatesStorage(GameObjectTemplate[] templates)
    {
        _templates = templates.ToDictionary(template => template.Name, template => template);
    }

    public GameObject BuildObject(string name, GameObjectsStorage objectsStorage)
    {
        GameObjectTemplate template = _templates[name];

        return InitObjects([template], objectsStorage, null, false).First();
    }
    
    public GameObject[] InitObjects(GameObjectTemplate[] objectsData, GameObjectsStorage objectsStorage, GameObject? parentObject, bool load)
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

                GameObject[] children = InitObjects(objectData.Children, objectsStorage, parentObject, load);

                if (parentEntity != null)
                {
                    foreach (GameObject childObject in children)
                    {
                        parentEntity.Children.Add(childObject);
                    }
                }

                if (load)
                {
                    gameObject.Load();
                }

                return gameObject;
                
            }).ToArray();
    }

    private object[] ConvertEntities(Dictionary<string, JObject> entitiesJson)
    {
        int[] entitiesIndices = new int[entitiesJson.Count];
        int entityCounter = 0;
        
        object[] instances = entitiesJson.Select(entry =>
        {
            EntityGeneralParamsJson generalParams = entry.Value.ToObject<EntityGeneralParamsJson>()!;
            entitiesIndices[entityCounter++] = generalParams.EntityOrder;
            
            Type entityType = ModelRegistry.GetEntityTypeByName(entry.Key);

            return entry.Value.ToObject(entityType)!;
        }).ToArray();

        Array.Sort(instances, (val1, val2) =>
        {
           int index1 = entitiesIndices[Array.IndexOf(instances, val1)]; 
           int index2 = entitiesIndices[Array.IndexOf(instances, val2)];
           return index1 - index2;
        });
        
        return instances;
    }

    class EntityGeneralParamsJson
    {
        public int EntityOrder;
    }
}