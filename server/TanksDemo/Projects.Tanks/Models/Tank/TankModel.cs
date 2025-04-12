using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using GameResources;
using Logging;
using Network.Session;
using OSGI.Services;
using Platform.Models.General.World3d;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Services.Profile;

namespace Projects.Tanks.Models.Tank;

[ModelEntity(typeof(TankModelEntity))]
[Model]
internal class TankModel(long modelId) : ModelBase<ITankModelClient>(modelId), ObjectAttachListener.Attached, ObjectListener.Load, IResourceRequire
{
    [InjectService]
    private static UserProfileService UserProfileService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;


    public void ObjectLoaded()
    {
        TankSoundsEntity sounds = GetEntity<TankSoundsEntity>();
        
        PutData(typeof(TankSoundsStruct), new TankSoundsStruct()
        {
            EngineIdleSoundId = ResourceRegistry.GetNumericId(sounds.EngineIdleSoundId),
            StartMovingSoundId = ResourceRegistry.GetNumericId(sounds.StartMovingSoundId),
            MoveSoundId = ResourceRegistry.GetNumericId(sounds.MoveSoundId),
            ShotSoundId = ResourceRegistry.GetNumericId(sounds.ShotSoundId),
            ExplosionSoundId = ResourceRegistry.GetNumericId(sounds.ExplosionSoundId)
        });
    }
    
    public void ObjectAttached(NetworkSession session)
    {
        TankModelEntity entity = GetEntity<TankModelEntity>();

        ITankInfo tankInfo = entity.TankInfoObject.Adapt<ITankInfo>();

        TankSoundsStruct sounds = GetData<TankSoundsStruct>(typeof(TankSoundsStruct))!;
        
        Clients(Context, client => 
            client.InitObject(
                selfTank:true,
                
                name:UserProfileService.GetUserName(session),
                score:UserProfileService.GetUserExperience(session),
                
                damagedTextureId:ResourceRegistry.GetNumericId(tankInfo.GetDeadTextureResourceId()),
                sounds:sounds,
                
                health:4, //max health
                
                accuracy:1,//not used anywhere
                control:0, //current tank control bits
                
                gunY:70,
                gunZ:0,
                
                height:50,
                length:190,
                width:90,
                
                orientation:new Vector3d(),
                position:new Vector3d(),
                turretAngle:0,
                
                speed:100,
                turretSpeed:1
                ));
    }
    

    [NetworkMethod]
    private void SuicideCommand(byte reason)
    {
    }

    [NetworkMethod]
    private void FireCommand(Vector3d hitPoint, long targetId)
    {
        Clients(Context.Object, Context.Space.GetDeployedSessions(Context.Object), client => 
            client.Fire(hitPoint, targetId));
    }

    [NetworkMethod]
    private void MoveCommand(Vector3d position, Vector3d orientation, float turretAngle, int controls, float a)
    {
    }

    public void CollectGameResources(List<string> resourcesIds)
    {
        TankModelEntity entity = GetEntity<TankModelEntity>();
        ITankInfo tankInfo = entity.TankInfoObject.Adapt<ITankInfo>();

        resourcesIds.Add(tankInfo.GetDeadTextureResourceId());

        TankSoundsEntity sounds = GetEntity<TankSoundsEntity>();
        
        resourcesIds.AddRange([
            sounds.EngineIdleSoundId,
            sounds.StartMovingSoundId,
            sounds.MoveSoundId,
            sounds.ShotSoundId,
            sounds.ExplosionSoundId
        ]);
    }
}