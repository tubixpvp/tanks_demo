using Config;
using Core.Model.Registry;
using Network;
using OSGI.Services;
using ResourcesWebServer;
using SpacesCommons;
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
        ServerResources.Init();
        
        OSGi.Init();

        OSGi.GetService<ModelRegistry>().Init();
        OSGi.GetService<SpacesActivatorService>().Init();

        ResourcesHttpFileServer fileServer = new ResourcesHttpFileServer(launchParams);
        fileServer.Start();

        OSGi.GetService<ClientsNetworkService>().Start().Wait();
    }
}