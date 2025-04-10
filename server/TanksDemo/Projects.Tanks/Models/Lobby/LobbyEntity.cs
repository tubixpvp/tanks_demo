using Projects.Tanks.Models.Lobby.Configs;

namespace Projects.Tanks.Models.Lobby;

internal class LobbyEntity
{
    public string[] Armies;
    public string DefaultArmy;

    public TankInfo[] Tanks;
    public string DefaultTank;

    public MapInfo[] Maps;
}