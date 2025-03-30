using Config;
using Core.Model.Registry;
using Network;
using OSGI.Services;
using ResourcesWebServer;
using Utils;

namespace TanksDemo;

internal class ServerMain
{
    public static void Main(string[] startupArgs)
    {
        _ = new ServerMain(ParametersUtil.FromRunArguments(startupArgs));
    }

    private ServerMain(ParametersUtil launchParams)
    {
        //the server starts here

        ServerLaunchParams.Init(launchParams);
        ServerConfig.Init();
        
        OSGi.Init();

        OSGi.GetService<ModelRegistry>().Init();

        ResourcesHttpFileServer fileServer = new ResourcesHttpFileServer(launchParams);
        fileServer.Start();

        OSGi.GetService<ClientsNetworkService>().Start().Wait();
    }
}