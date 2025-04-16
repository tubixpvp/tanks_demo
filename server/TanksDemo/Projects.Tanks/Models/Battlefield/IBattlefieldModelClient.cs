namespace Projects.Tanks.Models.Battlefield;

public interface IBattlefieldModelClient
{
    public void TankHealthChanged(long tankId, int newHealth);
    
    public void TankScoreChanged(long tankId, int newScore);
}