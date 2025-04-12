using Core.GameObjects;

namespace Projects.Tanks.Models.Lobby;

internal class LobbySessionData
{
    public required GameObject SelectedTank { get; set; }
    public required long SelectedArmyId { get; set; }
    public required long SelectedBattleId { get; set; }
}