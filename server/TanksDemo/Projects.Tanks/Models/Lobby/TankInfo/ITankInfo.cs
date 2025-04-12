using Projects.Tanks.Models.Lobby.ArmyInfo;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby.TankInfo;

internal interface ITankInfo
{
    public string GetName();
    
    public string GetModelResourceId();
    public string GetTextureResourceId(ArmyType armyType);
    public string GetDeadTextureResourceId();
    
    public TankStruct GetTankStruct();
}