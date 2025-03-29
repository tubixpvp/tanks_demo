using System.Xml.Linq;
using Config;
using Network;
using OSGI.Services;
using ResourcesBuilder;
using Utils;

namespace ProdFileServer;

[Service]
internal class ServerConfigXMLService
{
    [InjectService]
    private static ClientsNetworkService NetworkService;

    [InjectService]
    private static SWFLibrariesDataService LibsDataService;


    private Dictionary<string, SWFLibraryData>? _libsData;

    public string GetConfigXML()
    {
        if (_libsData == null)
        {
            string clientDir = ServerLaunchParams.GetLaunchParams().GetString("clientDir") ?? throw new Exception("Client dir is not provided");

            _libsData = LibsDataService.GetLibsData(clientDir).GetAwaiter().GetResult();
        }

        foreach (var entry in _libsData)
        {
            (int high, int low) = LongUtils.GetLongHighLow(entry.Value.ResourceId);
            
            Console.WriteLine(entry.Key + $"   ({high},{low})");
        }
        
        int[] ports = NetworkService.GetNetConfig().ClientPorts;

        string xml = new XElement("root",
            
            new XElement("server",
                
                new XElement("ports",
                    ports.Select(port => new XElement("port", port))
                ),
                
                new XElement("ip", "127.0.0.1") //todo
                
            ),
            
            new XElement("plugins",
                _libsData.Select(entry => 
                    new XElement("plugin",
                        new XAttribute("name", entry.Key),
                        new XAttribute("id", entry.Value.ResourceId),
                        new XAttribute("version", entry.Value.ResourceVersion)
                    ))
            )
            
        ).ToString();

        //Console.WriteLine(xml);
        
        return xml;
    }
}