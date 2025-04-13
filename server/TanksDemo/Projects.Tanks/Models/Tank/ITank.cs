using Network.Session;

namespace Projects.Tanks.Models.Tank;

internal interface ITank
{
    public NetworkSession? GetOwnerSession();
}