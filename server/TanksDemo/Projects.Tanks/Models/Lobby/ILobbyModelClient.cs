using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby;

public interface ILobbyModelClient
{
    public void InitObject(ArmyStruct[] armies,
        long defaultArmy,
        long defaultMap,
        long defaultTank,
        MapStruct[] maps,
        int selfScore,
        bool showRegButton,
        TankStruct[] tanks,
        TopRecord[] top10
    );
    
    
}