using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using GameResources;
using Logging;
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
internal class TankModel(long modelId) : ModelBase<ITankModelClient>(modelId), IClientConstructor<TankCC>, ObjectListener.Load, IResourceRequire, ITank, ObjectAttachListener.Detached
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

        GetLogger().Log(LogLevel.Info, "Tank.InitObject() " + Context.Object);
    }
    
    public TankCC GetClientInitData()
    {
        TankModelEntity entity = GetEntity<TankModelEntity>();

        ITankInfo tankInfo = entity.TankInfoObject.Adapt<ITankInfo>();

        TankSoundsStruct sounds = GetData<TankSoundsStruct>(typeof(TankSoundsStruct))!;
        TankData tankData = GetTankData();

        NetworkSession ownerControlSession = entity.ControlSession;
        NetworkSession? ownerSession = GetOwnerSession();
        
        return new TankCC()
        {
            SelfTank=ownerSession == Context.Session!,
                
            Name=UserProfileService.GetUserName(ownerControlSession),
            Score=UserProfileService.GetUserExperience(ownerControlSession),
                
            DamagedTextureId=ResourceRegistry.GetNumericId(tankInfo.GetDeadTextureResourceId()),
            Sounds=sounds,
            PaintResourceId=ResourceRegistry.GetNumericId(tankInfo.GetTextureResourceId(entity.ArmyType)),
                
            Health=(byte)tankInfo.GetMaxHealth(), //max health
                
            Accuracy=1,//not used anywhere
            Control=tankData.Controls, //current tank control bits
                
            GunY=70,
            GunZ=20,
                
            Height=50,
            Length=190,
            Width=90,
                
            Orientation=tankData.Orientation.ToVector3d(),
            Position=tankData.Position.ToVector3d(),
            TurretAngle=tankData.TurretAngle,
                
            Speed=100,
            TurretSpeed=1
        };
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