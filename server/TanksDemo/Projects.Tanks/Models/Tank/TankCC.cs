using Platform.Models.General.World3d;

namespace Projects.Tanks.Models.Tank;

internal class TankCC
{
    public required float Accuracy;
    public required int Control;
    public required long DamagedTextureId;
    public required float GunY, GunZ;
    public required float Height;
    public required byte Health;
    public required float Length;
    public required string Name;
    public required Vector3d Orientation;
    public required Vector3d Position;
    public required int Score;
    public required bool SelfTank;
    public required float Speed;
    public required float TurretAngle;
    public required float TurretSpeed;
    public required float Width;
    public required TankSoundsStruct Sounds;
    public required long PaintResourceId;
}