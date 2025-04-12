using OSGI.Services;
using Projects.Tanks.Models.Lobby.Struct;

namespace Projects.Tanks.Services.UserTop;

[Service]
internal class UserTopService
{

    public TopRecord[] GetTopRecords(int count)
    {
        return [];
    }
    
}