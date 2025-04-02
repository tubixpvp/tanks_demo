using System.Net;
using System.Text;
using Config;
using Logging;
using OSGI.Services;
using Utils;

namespace ResourcesWebServer;

public class ResourcesHttpFileServer
{
    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static ServerStatusService ServerStatus;
    
    [InjectService]
    private static ServerConfigXMLService ServerConfigXML;
    
    
    private readonly HttpListener _listener;

    private readonly string _resourcesRoot;

    private readonly ILogger _logger;

    private readonly byte[] _crossdomainXMLData;

    private bool _running;
    
    public ResourcesHttpFileServer(ParametersUtil launchParams)
    {
        _logger = LoggerService.GetLogger(GetType());
        
        int port = launchParams.GetInt("fileServPort") ?? throw new Exception("File server port is not provided");

        bool isProd = launchParams.GetBoolean("prod");

        _resourcesRoot = Path.GetFullPath(launchParams.GetString("resourcesPath") ?? throw new Exception("Resources path is not provided"));

        _logger.Log(LogLevel.Info,
            "Preparing file server for directory: " + _resourcesRoot);
        
        _listener = new HttpListener();

        if (isProd)
        {
            _listener.Prefixes.Add($"http://+:{port}/");
        }
        else
        {
            _listener.Prefixes.Add($"http://localhost:{port}/");
            _listener.Prefixes.Add($"http://127.0.0.1:{port}/");
        }

        _crossdomainXMLData = Encoding.UTF8.GetBytes(ServerResources.GetTextData("FileServer/crossdomain.xml"));
    }

    public Task Start()
    {
        _running = true;
        return SafeTask.Run(HandleTask, null);
    }

    private async Task HandleTask()
    {
        _listener.Start();
        
        _logger.Log(LogLevel.Info, "HTTP File server has started on " + _listener.Prefixes.First());
        
        while (_running)
        {
            HttpListenerContext context = await _listener.GetContextAsync();
            
            HttpListenerRequest request = context.Request;
            HttpListenerResponse response = context.Response;
            
            _logger.Log(LogLevel.Debug, 
                $"New request, type={request.HttpMethod}, url={request.Url!.LocalPath}");

            if (request.HttpMethod != "GET")
            {
                response.Close();
                continue;
            }

            string url = request.Url.LocalPath;

            url = url.Replace('\\', '/');
            url = url.Replace("../", "");
            url = url.Replace("..", "/");
            
            while (url.StartsWith('/'))
            {
                url = url[1..];
            }

            if (url == "crossdomain.xml")
            {
                await SendData(response, _crossdomainXMLData);
                continue;
            }
            
            if (url == "status.xml")
            {
                await SendData(response, 
                    await ServerStatus.GetStatusXML());
                continue;
            }
            if (url == "alternativa.cfg")
            {
                await SendData(response, ServerConfigXML.GetConfigXML());
                continue;
            }

            string realFilePath = Path.Combine(_resourcesRoot, url);

            if (!realFilePath.StartsWith(_resourcesRoot)) //somehow escaped
            {
                response.Close();
                continue;
            }
            
            _logger.Log(LogLevel.Debug, "filePath = " + realFilePath);

            SafeTask.Run(() => SendFile(response, realFilePath), null);
        }
    }

    private async Task SendData(HttpListenerResponse response, string data)
    {
        await SendData(response, Encoding.UTF8.GetBytes(data));
    }
    private async Task SendData(HttpListenerResponse response, byte[] data)
    {
        response.ContentType = "application/octet-stream";
        response.ContentLength64 = data.LongLength;
            
        await response.OutputStream.WriteAsync(data, 0, data.Length);
        
        response.Close();
    }

    private async Task SendFile(HttpListenerResponse response, string filePath)
    {
        if (!File.Exists(filePath))
        {
            response.StatusCode = 404;
            response.Close();

            _logger.Log(LogLevel.Debug, "File not found: " + filePath);
            
            return;
        }

        byte[] data = await File.ReadAllBytesAsync(filePath);

        await SendData(response, data);
    }
}