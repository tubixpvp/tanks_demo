using Core.Model;
using Core.Model.Communication;

namespace Platform.Models.Core.Quadro;

[Model]
public class QuadroModel(long id) : ModelBase<IQuadroModelClient>(id)
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