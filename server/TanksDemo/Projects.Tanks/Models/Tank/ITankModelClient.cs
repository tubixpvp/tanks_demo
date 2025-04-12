using Platform.Models.General.World3d;

namespace Projects.Tanks.Models.Tank;

internal interface ITankModelClient
{
    public void InitObject(float accuracy,
        int control,
        long damagedTextureId,
        float gunY, float gunZ,
        float height,
        int health,
        float length,
        string name,
        Vector3d orientation,
        Vector3d position,
        int score,
        bool selfTank,
        float speed,
        float turretAngle,
        float turretSpeed,
        float width,
        TankSoundsStruct sounds);

    public void Fire(Vector3d targetPosition, long targetTankId);

    public void ChangeHealth(int newHealth);

    public void Kill();

    public void Respawn(Vector3d position, Vector3d orientation, float turretAngle);
}