using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using CoreModels.GameObjectLoader;
using CoreModels.Resources;
using GameResources;
using Network.Session;
using OSGI.Services;
using Platform.Models.Core.Parent;
using Projects.Tanks.Models.Lobby.ArmyInfo;
using Projects.Tanks.Models.Lobby.MapInfo;
using Projects.Tanks.Models.Lobby.Struct;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Services.Lobby;

namespace Projects.Tanks.Models.Lobby;

[ModelEntity(typeof(LobbyEntity))]
[Model]
internal class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id), IResourceRequire, ObjectAttachListener.Attached
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    [InjectService]
    private static ClientResourcesService ClientResourcesService;
    
    [InjectService]
    private static BattlesRegistry BattlesRegistry;

    
    private const string TanksInfoObject = "Tanks Info";
    private const string ArmiesInfoObject = "Armies Info";
    

    private IParent GetTanksInfoParent()
    {
        GameObject tankInfoRoot = Context.Space.ObjectsStorage.GetObject(TanksInfoObject)!;
        return tankInfoRoot.Adapt<IParent>();
    }
    private IParent GetArmiesInfoParent()
    {
        GameObject armiesInfoRoot = Context.Space.ObjectsStorage.GetObject(ArmiesInfoObject)!;
        return armiesInfoRoot.Adapt<IParent>();
    }

    public void ObjectAttached(NetworkSession session)
    {
        MapStruct[] maps = BattlesRegistry.GetActiveBattlesData();

        TankStruct[] tanks = GetTanksInfoParent().GetChildren().Select(
            tankObj => tankObj.Adapt<ITankInfo>().GetTankStruct()).ToArray();

        ArmyStruct[] armies = GetArmiesInfoParent().GetChildren().Select(
            armyObj => armyObj.Adapt<IArmyInfo>().GetArmyStruct()).ToArray();
        
        LobbyEntity entity = GetEntity<LobbyEntity>();
        
        Clients(Context.Object, [], client => 
            client.InitObject(armies,
                armies.First(army => army.ArmyName == entity.DefaultArmy).ArmyId,
                maps[0].Id,
                tanks.First(tank => tank.Name == entity.DefaultTank).Id,
                maps,
                12345,
                true,
                tanks,
                [
                    new TopRecord()
                    {
                        Name = "test",
                        Score = 100000
                    }
                ]));
    }
    
    public void CollectGameResources(List<string> resourcesIds)
    {
        resourcesIds.AddRange(GetMaps().Select(info => info.GetEntity().PreviewId));
    }

    private IMapInfo[] GetMaps()
    {
        GameObject mapsInfoRoot = Context.Space.ObjectsStorage.GetObject("Maps")!;

        GameObject[] mapsInfoObjects = mapsInfoRoot.Adapt<IParent>().GetChildren();
        
        return mapsInfoObjects.Select(mapObj => mapObj.Adapt<IMapInfo>()).ToArray();
    }


    [NetworkMethod]
    private void SelectTank(long tankId, long armyId)
    {
        ITankInfo tankInfo = GetTanksInfoParent().GetChild(tankId)!.Adapt<ITankInfo>();
        IArmyInfo armyInfo = GetArmiesInfoParent().GetChild(armyId)!.Adapt<IArmyInfo>();
        
        string modelId = tankInfo.GetModelResourceId();
        string textureId = tankInfo.GetTextureResourceId(armyInfo.GetArmyType());

        GameObject gameObject = Context.Object;
        NetworkSession session = Context.Session!;

        ResourceInfo[] resources = new[] { modelId, textureId }.Select(ResourceRegistry.GetResourceInfo).ToArray();
        
        ClientResourcesService.LoadResources(session, resources,
            gameObject.GetFunctionWrapper(() => OnTankResourcesLoaded(modelId, textureId), session));
    }
    private void OnTankResourcesLoaded(string modelId, string textureId)
    {
        Clients(Context, client =>
            client.ShowTank(ResourceRegistry.GetNumericId(modelId), ResourceRegistry.GetNumericId(textureId)));
    }

    [NetworkMethod]
    private void SelectMap(long mapId)
    {
        
    }

    [NetworkMethod]
    private void StartBattle()
    {
        
    }

    [NetworkMethod]
    private void Register()
    {
        
    }
}