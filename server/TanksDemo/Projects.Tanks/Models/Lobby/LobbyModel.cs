using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Models.Lobby;

[ModelEntity(typeof(LobbyEntity))]
[Model]
internal class LobbyModel(long id) : ModelBase<ILobbyModelClient>(id), ObjectListener.Load
{

    
    public void ObjectLoaded()
    {
        Clients(Context.Object, [], client => 
            client.InitObject([
                new ArmyStruct()
                {
                    ArmyId = 100,
                    ArmyName = "testarmy"
                }
            ],
                100,
                101,
                102,
                [
                    new MapStruct()
                    {
                        Id = 101,
                        Name = "testmap",
                        Description = "the test map",
                        TanksOnline = 0,
                        MaxTanksOnline = 10,
                        PreviewResourceId = 0
                    }
                ],
                100000,
                true,
                [
                    new TankStruct()
                    {
                        Id = 102,
                        Name = "testtank"
                    }
                ],
                [
                    new TopRecord()
                    {
                        Name = "testuser",
                        Score = 1000
                    },
                    new TopRecord()
                    {
                        Name = "testuser2",
                        Score = 1001
                    }
                ]));
    }


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