using Core.GameObjects;
using Network.Session;
using Projects.Tanks.Models.Lobby.ArmyInfo;

namespace Projects.Tanks.Models.Tank;

internal class TankModelEntity
{
    public required GameObject TankInfoObject { get; init; }
    public required NetworkSession ControlSession { get; init; }
    public required ArmyType ArmyType { get; init; }
}