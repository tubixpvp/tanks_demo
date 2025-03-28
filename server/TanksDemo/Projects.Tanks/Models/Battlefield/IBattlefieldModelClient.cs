using Projects.Tanks.Models.Battlefield.Struct;

namespace Projects.Tanks.Models.Battlefield;

public interface IBattlefieldModelClient
{
    public void InitObject(long environmentSoundResourceId,
        long minimapResourceId,
        TankHealth[] tankHealths,
        TankScore[] tanksScores);

    public void TankHealthChanged(long tankId, int newHealth);
    
    public void TankScoreChanged(long tankId, int newScore);
}