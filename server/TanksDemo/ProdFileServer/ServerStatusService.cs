using System.Xml.Linq;
using OSGI.Services;

namespace ProdFileServer;

[Service]
internal class ServerStatusService
{

    public async Task<string> GetStatusXML()
    {
        //todo
        
        XElement element = new XElement("root", 
            new XElement("code", "available"));

        return element.ToString();
    }
}