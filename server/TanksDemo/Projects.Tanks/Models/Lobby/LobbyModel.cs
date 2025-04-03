using Core.Model;
using Core.Model.Communication;

namespace Projects.Tanks.Models.Lobby;

[Model]
public class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id)
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