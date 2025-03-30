using System.Reflection;
using Logging;
using Newtonsoft.Json.Linq;

namespace Config;

public static class ServerConfig
{
    private const string ResourcesFolder = "Resources";

    private static readonly ILogger _logger = new LoggerService().GetLogger(typeof(ServerConfig));

    private static readonly Dictionary<string, JObject> _configs = new();
    
    public static void Init()
    {
        string binFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        string configsRoot = Path.Combine(binFolder, ResourcesFolder);
        
        _logger.Log(LogLevel.Info, 
            $"Loading configs from {configsRoot}");

        string[] configsPaths = Directory.GetFiles(configsRoot, "*.json", SearchOption.AllDirectories);

        foreach (string configPath in configsPaths)
        {
            JObject json = JObject.Parse(File.ReadAllText(configPath));
            
            string fileName = Path.GetFileName(configPath);
            
            _configs.Add(fileName, json);
        }
    }

    public static T GetConfig<T>(string fileName)
    {
        return _configs[fileName].ToObject<T>()!;
    }
    
}