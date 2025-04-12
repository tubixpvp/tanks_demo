namespace Projects.Tanks.Models.Lobby;

internal class LobbySessionData
{
    public required long SelectedTankId { get; set; }
    public required long SelectedArmyId { get; set; }
    public required long SelectedBattleId { get; set; }
}