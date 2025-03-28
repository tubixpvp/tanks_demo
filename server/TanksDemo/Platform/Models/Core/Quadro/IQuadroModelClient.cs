namespace Platform.Models.Core.Quadro;

public interface IQuadroModelClient
{
    public void InitObject(int x, int y);
    
    
    public void SetClientPosition(int x, int y);

    public void Ping();
}