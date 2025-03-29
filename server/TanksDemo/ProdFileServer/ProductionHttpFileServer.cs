using System.Net;
using Utils;

namespace ProdFileServer;

public class ProductionHttpFileServer
{
    private readonly Thread _thread;

    private bool _running;
    
    public ProductionHttpFileServer(ParametersUtil launchParams)
    {
        _thread = new Thread(ReadingThread);
    }

    public Thread Start()
    {
        _running = true;
        _thread.Start();
        return _thread;
    }

    private void ReadingThread()
    {
        HttpListener listener = new HttpListener();
        
        listener.Prefixes.Add("*");
        
        while (_running)
        {
            
        }
    }
}