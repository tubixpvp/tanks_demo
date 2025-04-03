using Core.Model;
using Core.Model.Communication;

namespace Projects.Tanks.Models.Battlefield;

[Model]
public class BattlefieldModel(long id) : ModelBase<IBattlefieldModelClient>(id)
{


    [NetworkMethod]
    private void Leave()
    {
        
    }
}