using Projects.Tanks.Models.Battlefield.Struct;

namespace Projects.Tanks.Models.Battlefield;

internal class BattlefieldCC
{
    public required long EnvironmentSoundResourceId;
    public required long MinimapResourceId;
    public required TankHealth[] TankHealths;
    public required TankScore[] TanksScores;
}