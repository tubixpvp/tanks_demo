using Core.Model;
using Core.Model.Communication;
using GameResources;
using Network.Session;
using OSGI.Services;
using SpacesCommons.ClientControl;

namespace Projects.Tanks.Models.Battlefield;

[ModelEntity(typeof(BattlefieldEntity))]
[Model]
internal class BattlefieldModel(long id) : ModelBase<object>(id), IClientConstructor<BattlefieldCC>, IResourceRequire
{
    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    [InjectService]
    private static ClientSpacesControlService ClientSpacesControlService;

    
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

    public BattlefieldCC GetClientInitData()
    {
        BattlefieldEntity entity = GetEntity<BattlefieldEntity>();

        return new BattlefieldCC()
        {
            EnvironmentSoundResourceId = ResourceRegistry.GetNumericId(entity.EnvironmentSoundId),
            MinimapResourceId = ResourceRegistry.GetNumericId(entity.MinimapResourceId),
            TankHealths = [],
            TanksScores = []
        };
    }
}