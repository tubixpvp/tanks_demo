using Core.Model;

namespace Projects.Tanks.Models.Lobby.MapInfo;

[ModelEntity(typeof(MapInfoEntity))]
[Model(ServerOnly = true)]
internal class MapInfoModel(long modelId) : ModelBase<object>(modelId), IMapInfo
{
    
    public MapInfoEntity GetEntity() => GetEntity<MapInfoEntity>();
    
}