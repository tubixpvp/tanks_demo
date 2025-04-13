using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using Core.Spaces;
using CoreModels.Resources;
using GameResources;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using Platform.Models.Core.Parent;
using Projects.Tanks.Models.Lobby.ArmyInfo;
using Projects.Tanks.Models.Lobby.MapInfo;
using Projects.Tanks.Models.Lobby.Struct;
using Projects.Tanks.Models.Lobby.TankInfo;
using Projects.Tanks.Services.Battles;
using Projects.Tanks.Services.Profile;
using Projects.Tanks.Services.UserTop;

namespace Projects.Tanks.Models.Lobby;

[ModelEntity(typeof(LobbyEntity))]
[Model]
internal class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id), IClientConstructor<LobbyCC>, IResourceRequire, ObjectListener.Load
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;
    
    [InjectService]
    private static ClientResourcesService ClientResourcesService;
    
    [InjectService]
    private static BattlesRegistry BattlesRegistry;
    
    [InjectService]
    private static UserProfileService UserProfileService;
    
    [InjectService]
    private static UserTopService UserTopService;

    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static BattleJoinService BattleJoinService;


    private static readonly Random Random = new();

    
    private const string TanksInfoObject = "Tanks Info";
    private const string ArmiesInfoObject = "Armies Info";


    private const string SessionDataKey = "LobbySessionData";



    public void ObjectLoaded()
    {
        GameObject[] maps = GetMapsObjects();
        
        int battlesNumber = 5;
        for (int i = 0; i < battlesNumber; i++)
        {
            BattlesRegistry.CreateBattle(maps[Random.Next(0, maps.Length)]);
        }
    }
    
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

    public LobbyCC GetClientInitData()
    {
        NetworkSession session = Context.Session!;
        
        MapStruct[] maps = BattlesRegistry.GetActiveBattlesData();

        TankStruct[] tanks = GetTanksInfoParent().GetChildren().Select(
            tankObj => tankObj.Adapt<ITankInfo>().GetTankStruct()).ToArray();

        ArmyStruct[] armies = GetArmiesInfoParent().GetChildren().Select(
            armyObj => armyObj.Adapt<IArmyInfo>().GetArmyStruct()).ToArray();
        
        LobbyEntity entity = GetEntity<LobbyEntity>();

        LobbySessionData sessionData = GetSessionData(session);
        
        return new LobbyCC()
        {
            Armies = armies,
            DefaultArmy = sessionData.SelectedArmy.Id,
            DefaultMap = sessionData.SelectedBattleId,
            DefaultTank = tanks.First(tank => tank.Name == entity.DefaultTank).Id,
            Maps = maps,
            SelfScore = UserProfileService.GetUserExperience(session),
            ShowRegButton = !UserProfileService.IsRegistered(session),
            Tanks = tanks,
            Top10 = UserTopService.GetTopRecords(10)
        };
    }
    
    public void CollectGameResources(List<string> resourcesIds)
    {
        resourcesIds.AddRange(GetMaps().Select(info => info.GetEntity().PreviewId));
        foreach (GameObject tankInfoObj in GetTanksInfoParent().GetChildren())
        {
            tankInfoObj.Events<IResourceRequire>().CollectGameResources(resourcesIds);
        }
    }

    private IMapInfo[] GetMaps()
    {
        return GetMapsObjects().Select(mapObj => mapObj.Adapt<IMapInfo>()).ToArray();
    }
    private GameObject[] GetMapsObjects()
    {
        GameObject mapsInfoRoot = Context.Space.ObjectsStorage.GetObject("Maps")!;

        return mapsInfoRoot.Adapt<IParent>().GetChildren();
    }


    [NetworkMethod]
    private void SelectTank(long tankId, long armyId)
    {
        GameObject tankInfoObject = GetTanksInfoParent().GetChild(tankId)!;
        ITankInfo tankInfo = tankInfoObject.Adapt<ITankInfo>();

        GameObject armyInfoObject = GetArmiesInfoParent().GetChild(armyId)!;
        IArmyInfo armyInfo = armyInfoObject.Adapt<IArmyInfo>();
        
        LobbySessionData sessionData = GetSessionData(Context.Session!);

        sessionData.SelectedTank = tankInfoObject;
        sessionData.SelectedArmy = armyInfoObject;
        
        string modelId = tankInfo.GetModelResourceId();
        string textureId = tankInfo.GetTextureResourceId(armyInfo.GetArmyType());
        
        Clients(Context, client =>
            client.ShowTank(ResourceRegistry.GetNumericId(modelId), ResourceRegistry.GetNumericId(textureId)));
    }

    [NetworkMethod]
    private void SelectMap(long mapId)
    {
        if (!BattlesRegistry.IsBattleExists(mapId))
            return;

        GetSessionData(Context.Session!).SelectedBattleId = mapId;
    }

    [NetworkMethod]
    private void StartBattle()
    {
        NetworkSession session = Context.Session!;
        
        LobbySessionData sessionData = GetSessionData(session);
        
        Space battleSpace = BattlesRegistry.GetBattleSpaceById(sessionData.SelectedBattleId);

        IArmyInfo armyInfo = sessionData.SelectedArmy.Adapt<IArmyInfo>();

        BattleJoinService.JoinBattle(battleSpace, session, sessionData.SelectedTank, armyInfo.GetArmyType());
    }

    [NetworkMethod]
    private void Register()
    {
        
    }

    private LobbySessionData GetSessionData(NetworkSession session)
    {
        LobbySessionData? data = session.GetAttribute<LobbySessionData>(SessionDataKey);
        if (data == null)
        {
            LobbyEntity entity = GetEntity<LobbyEntity>();

            GameObject defaultTankObject = GetTanksInfoParent().GetChildren().First(
                gameObject => gameObject.Adapt<ITankInfo>().GetName() == entity.DefaultTank);
            GameObject defaultArmyObject = GetArmiesInfoParent().GetChildren().First(
                gameObject => gameObject.Adapt<IArmyInfo>().GetArmyType() == entity.DefaultArmy);
            
            data = new LobbySessionData()
            {
                //set default params
                SelectedTank = defaultTankObject,
                SelectedArmy = defaultArmyObject,
                SelectedBattleId = BattlesRegistry.GetFirstBattleId(),
            };
            session.SetAttribute(SessionDataKey, data);
        }
        return data;
    }
}