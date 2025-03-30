using System.Xml.Linq;
using Config;
using Network;
using OSGI.Services;
using ResourcesBuilder;

namespace ProdFileServer;

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

        Dictionary<string, SWFLibraryData> libsData = LibsDataService.GetLibsData(clientDir).GetAwaiter().GetResult();
            
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
                
                new XElement("ip", "127.0.0.1") //todo
                
            ),
            
            new XElement("plugins",
                libsData.Select(entry => 
                    new XElement("plugin",
                        new XAttribute("name", entry.Key),
                        new XAttribute("id", entry.Value.ResourceId),
                        new XAttribute("version", entry.Value.ResourceVersion)
                    ))
            )
            
        ).ToString();

        return _xmlString;
    }
}