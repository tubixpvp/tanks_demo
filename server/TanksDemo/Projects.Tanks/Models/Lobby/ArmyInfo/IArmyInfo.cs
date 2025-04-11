using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby.ArmyInfo;

internal interface IArmyInfo
{
    public ArmyType GetArmyType();
    
    public ArmyStruct GetArmyStruct();
}