using Core.GameObjects;
using Core.Model;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby.ArmyInfo;

[ModelEntity(typeof(ArmyInfoEntity))]
[Model(ServerOnly = true)]
internal class ArmyInfoModel(long modelId) : ModelBase<object>(modelId), IArmyInfo, ObjectListener.Load
{

    public void ObjectLoaded()
    {
        PutData(typeof(ArmyStruct), new ArmyStruct()
        {
            ArmyId = Context.Object.Id,
            ArmyName = GetEntity<ArmyInfoEntity>().Name
        });
    }

    public ArmyType GetArmyType() => GetEntity<ArmyInfoEntity>().Type;

    public ArmyStruct GetArmyStruct() => GetData<ArmyStruct>(typeof(ArmyStruct))!;
    
}