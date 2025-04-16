using System.Xml.Linq;
using Config;
using Network;
using OSGI.Services;
using ResourcesBuilder;

namespace ResourcesWebServer;

[Service]
internal class ServerConfigXMLService
{
    [InjectService]
    private static ClientsNetworkService NetworkService;

    [InjectService]
    private static SWFLibrariesDataService LibsDataService;
    

    private string? _xmlString;

    public string GetConfigXML()
    {
        if (_xmlString != null) 
            return _xmlString;
        
        string clientDir = ServerLaunchParams.GetLaunchParams().GetString("clientDir") ?? throw new Exception("Client dir is not provided");

        List<SWFLibraryData> libsData = LibsDataService.GetLibsData(clientDir).GetAwaiter().GetResult();
            
        /*foreach (var entry in libsData)
        {
            (int high, int low) = LongUtils.GetLongHighLow(entry.Value.ResourceId);
            
            Console.WriteLine(entry.Key + $"   ({high},{low})");
        }*/
        
        int[] ports = NetworkService.GetNetConfig().ClientPorts;

        _xmlString = new XElement("root",
            
            new XElement("server",
                
                new XElement("ports",
                    ports.Select(port => new XElement("port", port))
                ),
                
                new XAttribute("ip", "localhost") //todo
                
            ),
            
            new XElement("plugins",
                libsData.Select(lib => 
                    new XElement("plugin",
                        new XAttribute("name", lib.Name),
                        new XAttribute("id", lib.ResourceId),
                        new XAttribute("version", lib.ResourceVersion)
                    ))
            )
            
        ).ToString();

        return _xmlString;
    }
}