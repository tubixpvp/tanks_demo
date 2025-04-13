using Core.GameObjects;
using Core.Spaces;
using CoreModels.Resources;
using GameResources;
using Logging;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using Platform.Models.Core.Child;
using Platform.Models.General.World3d.A3D;
using Projects.Tanks.Models.Lobby.ArmyInfo;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Models.Tank;
using Projects.Tanks.Services.Profile;

namespace Projects.Tanks.Services.Battles;

[Service]
internal class BattleJoinService
{
    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static ClientResourcesService ClientResourcesService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    [InjectService]
    private static UserProfileService UserProfileService;

    [InjectService]
    private static LoggerService LoggerService;
    
    
    public void JoinBattle(Space battleSpace, NetworkSession spaceSession, GameObject selectedTankInfo, ArmyType armyType)
    {
        NetworkSession controlSession = SpaceChannelHandler.GetControlSessionBySpace(spaceSession);

        SpaceChannelHandler.DisconnectFromSpace(controlSession, spaceSession);

        GameObject tankObject = CreateTankObject(controlSession, battleSpace, selectedTankInfo, armyType);
        
        LoadAllSpaceResources(battleSpace, controlSession,
            () =>
            {
                SpaceChannelHandler.ConnectToSpace(controlSession, battleSpace);

                battleSpace.AttachObjectToAll(tankObject);
                
                tankObject.Params.AutoAttach = true;
            });
    }

    private void LoadAllSpaceResources(Space space, NetworkSession controlSession, Action callback)
    {
        //preload all battle resources
        
        GameObject[] objects = space.ObjectsStorage.GetObjects();

        List<string> requiredResourcesIds = new();

        foreach (GameObject gameObject in objects)
        {
            gameObject.Events<IResourceRequire>().CollectGameResources(requiredResourcesIds);
        }
        
        ResourceInfo[] uniqueResources = requiredResourcesIds
            .Distinct()
            .Select(ResourceRegistry.GetResourceInfo)
            .ToArray();

        ClientResourcesService.LoadResources(controlSession, uniqueResources, callback);
    }

    private GameObject CreateTankObject(NetworkSession controlSession, Space space, GameObject tankInfoObject, ArmyType armyType)
    {
        string objectName = $"tank@{UserProfileService.GetUserName(controlSession)}@{controlSession.Socket.IPAddress}";
        
        LoggerService.GetLogger(typeof(BattleJoinService)).Log(LogLevel.Info, 
            $"creating tank {objectName}");
        
        GameObject tankObj = space.ObjectsStorage.CreateObject(objectName,
            [
                new ChildModelEntity(),
                new TankModelEntity()
                {
                    TankInfoObject = tankInfoObject,
                    ControlSession = controlSession,
                    ArmyType = armyType
                },
                new A3DModelEntity()
                {
                    ModelResourceId = tankInfoObject.Adapt<ITankInfo>().GetModelResourceId(),
                    CollisionResourceId = null
                },
                tankInfoObject.Adapt<IChild>().GetParent().GetModelEntity<TankSoundsEntity>()
            ]);

        tankObj.Load();
        
        GameObject battleRootObject = space.ObjectsStorage.GetObject("Battlefield Root")!;
        tankObj.Adapt<IChild>().ChangeParent(battleRootObject);
        
        return tankObj;
    }


    public void OnDisconnected(NetworkSession spaceSession, GameObject tankObject)
    {
        tankObject.Params.AutoAttach = false;
        
        tankObject.UnloadAndDestroy();
    }
    
}