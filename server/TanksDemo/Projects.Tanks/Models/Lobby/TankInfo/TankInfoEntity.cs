using Projects.Tanks.Models.Lobby.ArmyInfo;

namespace Projects.Tanks.Models.Lobby.TankInfo;

internal class TankInfoEntity
{
    public string Name;

    public string ModelId;

    public Dictionary<ArmyType, string> Textures;

    public string DeadTextureId;

    public TankProperties Params;
}