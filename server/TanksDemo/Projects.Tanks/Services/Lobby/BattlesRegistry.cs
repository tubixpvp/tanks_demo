using Core.Spaces;
using GameResources;
using OSGI.Services;
using Platform.Models.Core.Parent;
using Projects.Tanks.Models.Lobby.MapInfo;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Services.Lobby;

[Service]
internal class BattlesRegistry
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    [InjectService]
    private static SpaceRegistry SpaceRegistry;

    
    private static readonly Random Random = new();

    
    public MapStruct[] GetActiveBattlesData()
    {
        //test:

        IParent mapsInfoParent = SpaceRegistry.GetSpaceByName("Lobby").ObjectsStorage.GetObject("Maps")!.Adapt<IParent>();
        IMapInfo mapInfo = mapsInfoParent.GetChildren().First().Adapt<IMapInfo>();
        
        int mapsCount = 5;
        MapStruct[] maps = new MapStruct[mapsCount];
        for (int i = 0; i < mapsCount; i++)
        {
            MapInfoEntity info = mapInfo.GetEntity();
            
            maps[i] = new MapStruct()
            {
                Id = Random.NextInt64(long.MinValue, long.MaxValue),
                Name = info.Name,
                Description = info.Description,
                TanksOnline = 0,//
                MaxTanksOnline = info.MaxTanks,
                PreviewResourceId = ResourceRegistry.GetNumericId(info.PreviewId)
            };
        }
        return maps;
    }
    
}