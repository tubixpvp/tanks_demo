using Core.Model;
using Core.Model.Communication;

namespace Projects.Tanks.Models.Battlefield;

[Model]
public class BattlefieldModel() : ModelBase<IBattlefieldModelClient>(491976761783110)
{


    [NetworkMethod]
    private void Leave()
    {
        
    }
}