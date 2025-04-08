using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using GameResources;
using OSGI.Services;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby;

[ModelEntity(typeof(LobbyEntity))]
[Model]
internal class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id), ObjectListener.Load
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    
    private static readonly Random Random = new();
    
    public void ObjectLoaded()
    {
        LobbyEntity entity = GetEntity<LobbyEntity>();

        //test data:
        
        ArmyStruct[] armies = entity.Armies.Select(
            name => new ArmyStruct()
            {
                ArmyName = name,
                ArmyId = Random.NextInt64(long.MinValue, long.MaxValue)
            }).ToArray();
        TankStruct[] tanks = entity.Tanks.Select(
            name => new TankStruct()
            {
                Name = name,
                Id = Random.NextInt64(long.MinValue, long.MaxValue)
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
                100000,
                true,
                tanks,
                []));
    }


    [NetworkMethod]
    private void SelectTank(long tankId, long armyId)
    {
        
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