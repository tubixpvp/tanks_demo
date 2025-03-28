using Core.Model.Registry;
using OSGI.Services;

namespace TanksDemo;

internal class ServerMain
{
    public static void Main(string[] startupArgs)
    {
        new ServerMain();
    }

    private ServerMain()
    {
        //the server starts here
        
        OSGi.Init();

        OSGi.GetService<ModelRegistry>().Init();
    }
}