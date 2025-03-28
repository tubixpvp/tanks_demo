using Core.Model;
using Core.Model.Communication;

namespace Platform.Models.Core.Quadro;

[Model]
public class QuadroModel() : ModelBase<IQuadroModelClient>(1893418631061)
{
    
    [NetworkMethod]
    private void SetPosition(float x, float y)
    {
        
    }

    [NetworkMethod]
    private void Pong()
    {
        
    }
}