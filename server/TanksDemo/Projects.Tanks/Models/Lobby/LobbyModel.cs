using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using CoreModels.GameObjectLoader;
using CoreModels.Resources;
using GameResources;
using Network.Session;
using OSGI.Services;
using Projects.Tanks.Models.Lobby.Configs;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby;

[ModelEntity(typeof(LobbyEntity))]
[Model]
internal class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id), ObjectListener.Load, IResourceRequire
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    [InjectService]
    private static ClientResourcesService ClientResourcesService;
    
    
    private static readonly Random Random = new();


    private readonly Dictionary<long, TankInfo> _tankInfoById = new();
    private readonly Dictionary<long, string> _armyNameById = new();
    
    public void ObjectLoaded()
    {
        LobbyEntity entity = GetEntity<LobbyEntity>();
        
        ArmyStruct[] armies = entity.Armies.Select(
            name =>
            {
                long id = Random.NextInt64(long.MinValue, long.MaxValue);
                _armyNameById.Add(id, name);
                return new ArmyStruct()
                {
                    ArmyName = name,
                    ArmyId = id
                };
            }).ToArray();
        
        TankStruct[] tanks = entity.Tanks.Select(
            info =>
            {
                long id = Random.NextInt64(long.MinValue, long.MaxValue);
                _tankInfoById.Add(id, info);
                return new TankStruct()
                {
                    Name = info.Name,
                    Id = id
                };
            }).ToArray();

        int mapsCount = 5;
        MapStruct[] maps = new MapStruct[mapsCount];
        for (int i = 0; i < mapsCount; i++)
        {
            MapInfo info = entity.Maps[Random.Next(0, entity.Maps.Length)];
            
            maps[i] = new MapStruct()
            {
                Id = Random.NextInt64(long.MinValue, long.MaxValue),
                Name = info.Name,
                Description = info.Description,
                TanksOnline = 0,
                MaxTanksOnline = info.MaxTanks,
                PreviewResourceId = ResourceRegistry.GetNumericId(info.PreviewId)
            };
        }
        
        Clients(Context.Object, [], client => 
            client.InitObject(armies,
                armies.First(army => army.ArmyName == entity.DefaultArmy).ArmyId,
                maps[0].Id,
                tanks.First(tank => tank.Name == entity.DefaultTank).Id,
                maps,
                4,
                true,
                tanks,
                [
                    new TopRecord()
                    {
                        Name = "test",
                        Score = 100
                    }
                ]));
    }
    
    public void CollectGameResources(List<string> resourcesIds)
    {
        LobbyEntity entity = GetEntity<LobbyEntity>();
        
        resourcesIds.AddRange(entity.Maps.Select(
            mapInfo => mapInfo.PreviewId));
        //resourcesIds.AddRange(entity.Tanks.Select(
        //    tankInfo => tankInfo.ModelId));
    }


    [NetworkMethod]
    private void SelectTank(long tankId, long armyId)
    {
        TankInfo tankInfo = _tankInfoById[tankId];
        
        string modelId = tankInfo.ModelId;
        string textureId = tankInfo.Textures[_armyNameById[armyId]];

        GameObject gameObject = Context.Object;
        NetworkSession session = Context.Session!;

        ResourceInfo[] resources = new[] { modelId, textureId }.Select(ResourceRegistry.GetResourceInfo).ToArray();
        
        ClientResourcesService.LoadResources(session, resources,
            gameObject.GetFunctionWrapper(() => OnTankResourcesLoaded(modelId, textureId), session));
    }
    private void OnTankResourcesLoaded(string modelId, string textureId)
    {
        Clients(Context, client =>
            client.ShowTank(ResourceRegistry.GetNumericId(modelId), ResourceRegistry.GetNumericId(textureId)));
    }

    [NetworkMethod]
    private void SelectMap(long mapId)
    {
        
    }

    [NetworkMethod]
    private void StartBattle()
    {
        
    }

    [NetworkMethod]
    private void Register()
    {
        
    }
}