using Newtonsoft.Json;

namespace Network;

public class ServerNetworkConfig
{
    [JsonProperty("client_ports")]
    public int[] ClientPorts;
}