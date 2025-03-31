using System.Text;
using OSGI.Services;

namespace Network.Sockets;

internal static class PolicyUtil
{
    [InjectService]
    private static ClientsNetworkService NetworkService;
    
    
    public const string PolicyFileRequest = "policy-file-request";


    private static byte[]? _policyData;

    public static byte[] PolicyData
    {
        get
        {
            if (_policyData == null)
            {
                int port = NetworkService.GetNetConfig().ClientPorts[0];
                _policyData = Encoding.UTF8.GetBytes($"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<cross-domain-policy>\n    <allow-access-from domain=\"*\" to-ports=\"{port}\"/>\n</cross-domain-policy>\0");
            }

            return _policyData;
        }
    }
}