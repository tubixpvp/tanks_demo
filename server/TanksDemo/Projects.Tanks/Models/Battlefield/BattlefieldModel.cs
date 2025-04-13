using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using GameResources;
using Network.Session;
using OSGI.Services;
using SpacesCommons.ClientControl;

namespace Projects.Tanks.Models.Battlefield;

[ModelEntity(typeof(BattlefieldEntity))]
[Model]
internal class BattlefieldModel(long id) : ModelBase<IBattlefieldModelClient>(id), ObjectListener.Load, IResourceRequire
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    [InjectService]
    private static ClientSpacesControlService ClientSpacesControlService;

    
    public void ObjectLoaded()
    {
        BattlefieldEntity entity = GetEntity<BattlefieldEntity>();
        
        Clients(Context, client => 
            client.InitObject(
                environmentSoundResourceId:ResourceRegistry.GetNumericId(entity.EnvironmentSoundId),
                minimapResourceId:ResourceRegistry.GetNumericId(entity.MinimapResourceId),
                tankHealths:[],
                tanksScores:[]
                ));
    }

    [NetworkMethod]
    private void Leave()
    {
        NetworkSession session = Context.Session!;

        ClientSpacesControlService.SwitchSpace(session, "Lobby");
    }

    public void CollectGameResources(List<string> resourcesIds)
    {
        BattlefieldEntity entity = GetEntity<BattlefieldEntity>();

        resourcesIds.Add(entity.EnvironmentSoundId);
        resourcesIds.Add(entity.MinimapResourceId);
    }
}