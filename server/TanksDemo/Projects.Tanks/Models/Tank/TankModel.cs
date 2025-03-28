using Core.Model;
using Core.Model.Communication;
using Platform.Models.General.World3d;

namespace Projects.Tanks.Models.Tank;

[Model]
public class TankModel() : ModelBase<ITankModelClient>(8891834178373)
{

    [NetworkMethod]
    private void SuicideCommand(byte reason)
    {
    }

    [NetworkMethod]
    private void FireCommand(Vector3d hitPoint, long targetId)
    {
    }

    [NetworkMethod]
    private void MoveCommand(Vector3d position, Vector3d orientation, float turretAngle, int controls, float a)
    {
    }
}