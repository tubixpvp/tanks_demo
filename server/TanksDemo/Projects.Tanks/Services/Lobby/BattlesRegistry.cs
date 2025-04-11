using Core.Spaces;
using GameResources;
using OSGI.Services;
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

        IMapInfo mapInfo = SpaceRegistry.GetSpaceByName("Lobby").ObjectsStorage.GetObject("Maps")!.Children
            .GetObjects().First().Adapt<IMapInfo>();
        
        int mapsCount = 5;
        MapStruct[] maps = new MapStruct[mapsCount];
        for (int i = 0; i < mapsCount; i++)
        {
            MapInfoEntity info = mapInfo.GetEntity();
            //MapInfo info = entity.Maps[Random.Next(0, entity.Maps.Length)];
            
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