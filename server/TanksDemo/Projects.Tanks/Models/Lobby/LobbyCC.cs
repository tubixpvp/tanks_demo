using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby;

internal class LobbyCC
{
    public required ArmyStruct[] Armies;
    public required long DefaultArmy;
    public required long DefaultMap;
    public required long DefaultTank;
    public required MapStruct[] Maps;
    public required int SelfScore;
    public required bool ShowRegButton;
    public required TankStruct[] Tanks;
    public required TopRecord[] Top10;
}