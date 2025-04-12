using Core.GameObjects;
using Core.Spaces;
using GameResources;
using OSGI.Services;
using Platform.Models.Core.Child;
using Projects.Tanks.Models.Lobby.MapInfo;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Services.Battles;

[Service]
internal class BattlesRegistry
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    [InjectService]
    private static SpaceRegistry SpaceRegistry;

    
    private static readonly Random Random = new();

    
    private readonly List<long> _battleSpaces = new();

    private long _battleCounter = 0;


    public void CreateBattle(GameObject mapInfoObject)
    {
        Space templateSpace = SpaceRegistry.GetSpaceByName("Battle Template");
        
        string battleName = "Battle" + (++_battleCounter);
        Space battleSpace = SpaceRegistry.CreateSpace(battleName, templateSpace.TemplatesStorage);

        
        MapInfoEntity mapInfoEntity = mapInfoObject.Adapt<IMapInfo>().GetEntity();

        GameObject battleMapInfo = battleSpace.ObjectsStorage.CreateObject("Map Info", [
            mapInfoEntity,
            new ChildModelEntity()
        ]);
        
        GameObject battleRootObject = battleSpace.TemplatesStorage.BuildObject("Battlefield Root", battleSpace.ObjectsStorage);

        battleMapInfo.Adapt<IChild>().ChangeParent(battleRootObject);
        
        _battleSpaces.Add(battleSpace.Id);
    }

    public Space GetBattleSpaceById(long id)
    {
        return SpaceRegistry.GetSpaceById(id);
    }
    
    public MapStruct[] GetActiveBattlesData()
    {
        return _battleSpaces.Select(
            id =>
            {
                Space space = SpaceRegistry.GetSpaceById(id);
                MapInfoEntity mapInfo = space.ObjectsStorage.GetObject("Map Info")!.GetModelEntity<MapInfoEntity>();
                
                return new MapStruct()
                {
                    Id = id,
                    Name = mapInfo.Name,
                    Description = mapInfo.Description,
                    TanksOnline = 0,//
                    MaxTanksOnline = mapInfo.MaxTanks,
                    PreviewResourceId = ResourceRegistry.GetNumericId(mapInfo.PreviewId)
                };
            }).ToArray();
    }

    public long GetFirstBattleId()
    {
        return _battleSpaces.First();
    }

    public bool IsBattleExists(long battleId)
    {
        return _battleSpaces.Contains(battleId);
    }
    
}