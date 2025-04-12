using Core.Generator;

namespace Projects.Tanks.Models.Tank;

[ClientExport]
internal class TankSoundsStruct
{
    public required long EngineIdleSoundId;
    public required long StartMovingSoundId;
    public required long MoveSoundId;

    public required long ShotSoundId;
    public required long ExplosionSoundId;
}