using Config;
using OSGI.Services;

namespace Network;

[Service]
public class ClientsNetworkService
{
    private readonly ServerNetworkConfig _netConfig;


    public ClientsNetworkService()
    {
        _netConfig = ServerConfig.GetConfig<ServerNetworkConfig>("network.json");
    }

    public ServerNetworkConfig GetNetConfig() => _netConfig;
}