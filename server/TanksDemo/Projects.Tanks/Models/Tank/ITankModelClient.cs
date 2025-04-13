using Platform.Models.General.World3d;

namespace Projects.Tanks.Models.Tank;

internal interface ITankModelClient
{
    public void Move(Vector3d position, Vector3d orientation, float turretAngle, int control, int timer);

    public void Fire(Vector3d targetPosition, long targetTankId);

    public void ChangeHealth(int newHealth);

    public void Kill();

    public void Respawn(Vector3d position, Vector3d orientation, float turretAngle);
}