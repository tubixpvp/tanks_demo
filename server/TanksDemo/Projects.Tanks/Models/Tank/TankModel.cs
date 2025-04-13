using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using GameResources;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using Platform.Models.General.World3d;
using Platform.Utils;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Services.Battles;
using Projects.Tanks.Services.Profile;

namespace Projects.Tanks.Models.Tank;

[ModelEntity(typeof(TankModelEntity))]
[Model]
internal class TankModel(long modelId) : ModelBase<ITankModelClient>(modelId), ObjectAttachListener.Attached, ObjectListener.Load, IResourceRequire, ITank, ObjectAttachListener.Detached
{
    [InjectService]
    private static UserProfileService UserProfileService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static BattleJoinService BattleJoinService;


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

        PutData(typeof(TankData), new TankData());
    }
    
    public void ObjectAttached(NetworkSession session)
    {
        TankModelEntity entity = GetEntity<TankModelEntity>();

        ITankInfo tankInfo = entity.TankInfoObject.Adapt<ITankInfo>();

        TankSoundsStruct sounds = GetData<TankSoundsStruct>(typeof(TankSoundsStruct))!;
        TankData tankData = GetTankData();

        NetworkSession ownerControlSession = entity.ControlSession;
        NetworkSession? ownerSession = GetOwnerSession();
        
        Clients(Context, client => 
            client.InitObject(
                selfTank:ownerSession == session,
                
                name:UserProfileService.GetUserName(ownerControlSession),
                score:UserProfileService.GetUserExperience(ownerControlSession),
                
                damagedTextureId:ResourceRegistry.GetNumericId(tankInfo.GetDeadTextureResourceId()),
                sounds:sounds,
                paintResourceId:ResourceRegistry.GetNumericId(tankInfo.GetTextureResourceId(entity.ArmyType)),
                
                health:(byte)tankInfo.GetMaxHealth(), //max health
                
                accuracy:1,//not used anywhere
                control:tankData.Controls, //current tank control bits
                
                gunY:70,
                gunZ:20,
                
                height:50,
                length:190,
                width:90,
                
                orientation:tankData.Orientation.ToVector3d(),
                position:tankData.Position.ToVector3d(),
                turretAngle:tankData.TurretAngle,
                
                speed:100,
                turretSpeed:1
                ));
    }
    
    public void ObjectDetached(NetworkSession session)
    {
        if (GetOwnerSession() == session)
        {
            //owner disconnected

            BattleJoinService.OnDisconnected(session, Context.Object);
        }
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
        TankData tankData = GetTankData();

        tankData.Position.CopyFromVector3d(position);
        tankData.Orientation.CopyFromVector3d(orientation);
        tankData.TurretAngle = turretAngle;
        tankData.Controls = controls;
        
        Clients(Context.Object, Context.Space.GetDeployedSessions(Context.Object).Except([Context.Session!]),
            client => client.Move(position, orientation, turretAngle, controls, 0));
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

    public NetworkSession? GetOwnerSession()
    {
        NetworkSession? spaceSession = GetData<NetworkSession>(typeof(NetworkSession));
        if (spaceSession == null)
        {
            NetworkSession controlSession = GetEntity<TankModelEntity>().ControlSession;

            spaceSession = SpaceChannelHandler.GetSpaceSession(controlSession, Context.Space);
            if (spaceSession == null)
                return null;

            PutData(typeof(NetworkSession), spaceSession);
        }
        return spaceSession;
    }

    private TankData GetTankData() => GetData<TankData>(typeof(TankData))!;
}