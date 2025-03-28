using Core.Model;
using Core.Model.Communication;

namespace Projects.Tanks.Models.Lobby;

[Model]
public class LobbyModel() : ModelBase<ILobbyModelClient>(1759917744118345)
{


    [NetworkMethod]
    private void SelectTank(long tankId, long armyId)
    {
        
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