using Core.GameObjects;
using Core.Model;
using Projects.Tanks.Models.Lobby.ArmyInfo;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby.TankInfo;

[ModelEntity(typeof(TankInfoEntity))]
[Model(ServerOnly = true)]
internal class TankInfoModel(long modelId) : ModelBase<object>(modelId), ITankInfo, ObjectListener.Load
{
    
    public void ObjectLoaded()
    {
        PutData(typeof(TankStruct), new TankStruct()
        {
            Id = Context.Object.Id,
            Name = GetName()
        });
    }
    
    
    public string GetName() => GetEntity<TankInfoEntity>().Name;

    public string GetModelResourceId() => GetEntity<TankInfoEntity>().ModelId;

    public string GetTextureResourceId(ArmyType type) => GetEntity<TankInfoEntity>().Textures[type];


    public TankStruct GetTankStruct() => GetData<TankStruct>(typeof(TankStruct))!;
    
}