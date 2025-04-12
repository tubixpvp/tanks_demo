using Core.GameObjects;
using Core.Spaces;
using CoreModels.Resources;
using GameResources;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using Platform.Models.Core.Child;
using Platform.Models.General.World3d.A3D;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Models.Tank;

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
    
    
    public void JoinBattle(Space battleSpace, NetworkSession spaceSession, GameObject selectedTankInfo)
    {
        NetworkSession controlSession = SpaceChannelHandler.GetControlSessionBySpace(spaceSession);

        SpaceChannelHandler.DisconnectFromSpace(controlSession, spaceSession);

        GameObject tankObject = CreateTankObject(spaceSession, battleSpace, selectedTankInfo);
        
        LoadAllSpaceResources(battleSpace, controlSession,
            () =>
            {
                SpaceChannelHandler.ConnectToSpace(controlSession, battleSpace);
            });
    }

    private void LoadAllSpaceResources(Space space, NetworkSession controlSession, Action callback)
    {
        //preload all battle resources
        
        GameObject[] objects = space.ObjectsStorage.GetObjects();

        List<string> requiredResourcesIds = new();

        foreach (GameObject gameObject in objects)
        {
            if(!gameObject.Params.AutoAttach)
                continue;
            gameObject.Events<IResourceRequire>().CollectGameResources(requiredResourcesIds);
        }
        
        ResourceInfo[] uniqueResources = requiredResourcesIds
            .Distinct()
            .Select(ResourceRegistry.GetResourceInfo)
            .ToArray();

        ClientResourcesService.LoadResources(controlSession, uniqueResources, callback);
    }

    private GameObject CreateTankObject(NetworkSession session, Space space, GameObject tankInfoObject)
    {
        GameObject tankObj = space.ObjectsStorage.CreateObject("tank@" + session.Socket.IPAddress,
            [
                new ChildModelEntity(),
                new TankModelEntity()
                {
                    TankInfoObject = tankInfoObject
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
        
        tankObj.Params.AutoAttach = true;
        
        return tankObj;
    }
    
}