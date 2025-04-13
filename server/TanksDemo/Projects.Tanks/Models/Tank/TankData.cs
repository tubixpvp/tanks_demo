using Utils.Maths;

namespace Projects.Tanks.Models.Tank;

internal class TankData
{
    public Vector3 Position { get; } = new();
    public Vector3 Orientation { get; } = new();
    public float TurretAngle { get; set; } = 0;
    public int Controls { get; set; } = 0;
}