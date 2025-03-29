using Config;
using Core.Model.Registry;
using OSGI.Services;
using ProdFileServer;
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

        ProductionHttpFileServer fileServer = new ProductionHttpFileServer(launchParams);

        fileServer.Start().Wait();
    }
}