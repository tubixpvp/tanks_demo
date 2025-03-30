using System.Net;
using System.Net.Sockets;
using Config;
using Logging;
using Network.Session;
using Network.Sockets;
using OSGI.Services;
using Utils;

namespace Network;

[Service]
public class ClientsNetworkService : IOSGiInitListener
{
    [InjectService]
    private static LoggerService LoggerService;
    
    [InjectService]
    private static NetworkSessionsRegistry SessionsRegistry;
    
    
    private readonly ServerNetworkConfig _netConfig;

    private readonly TcpListener _tcpListener;
    
    private ILogger _logger;

    private bool _running;

    public ClientsNetworkService()
    {
        _netConfig = ServerResources.GetConfig<ServerNetworkConfig>("network.json");

        _tcpListener = new TcpListener(IPAddress.Any, _netConfig.ClientPorts[0]);
    }
    
    public void OnOSGiInited()
    {
        _logger = LoggerService.GetLogger(GetType());
    }

    public ServerNetworkConfig GetNetConfig() => _netConfig;


    public Task Start()
    {
        _running = true;
        return SafeTask.Run(ConnectionsAcceptTask);
    }

    private async Task ConnectionsAcceptTask()
    {
        _tcpListener.Start();
        
        _logger.Log(LogLevel.Info, 
            "Clients TCP listener has started on port: " + string.Join(',',_netConfig.ClientPorts));

        while (_running)
        {
            Socket socket = await _tcpListener.AcceptSocketAsync();

            HandleNewConnection(socket);
        }
    }

    private void HandleNewConnection(Socket socket)
    {
        NetSocket netSocket = new NetSocket(socket);
        
        _logger.Log(LogLevel.Info, 
            $"New client has connected from IP: {netSocket.IPAddress}");

        NetworkSession session = new NetworkSession(netSocket);

        SessionsRegistry.AddSession(session);
    }
}