using System.Reflection;
using Logging;
using Newtonsoft.Json.Linq;

namespace Config;

public static class ServerResources
{
    private const string ResourcesFolder = "Resources";

    private static readonly ILogger Logger = new LoggerService().GetLogger(typeof(ServerResources));

    private static readonly Dictionary<string, JObject> Configs = new();

    private static readonly Dictionary<string, string> TextFiles = new();
    
    public static void Init()
    {
        string binFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        string configsRoot = Path.Combine(binFolder, ResourcesFolder);
        
        Logger.Log(LogLevel.Info, 
            $"Loading configs from {configsRoot}");

        string[] configsPaths = Directory.GetFiles(configsRoot, "*.json", SearchOption.AllDirectories);

        foreach (string configPath in configsPaths)
        {
            JObject json = JObject.Parse(File.ReadAllText(configPath));
            
            string fileName = Path.GetFileName(configPath);
            
            Configs.Add(fileName, json);
        }
        
        
        string[] otherConfigsPaths = Directory.GetFiles(configsRoot, "*", SearchOption.AllDirectories);

        foreach (string configPath in otherConfigsPaths.Except(configsPaths))
        {
            string fileName = Path.GetFileName(configPath);
            
            string text = File.ReadAllText(configPath);
            
            TextFiles.Add(fileName, text);
        }
    }

    public static T GetConfig<T>(string fileName)
    {
        return Configs[fileName].ToObject<T>()!;
    }

    public static string GetTextData(string fileName)
    {
        return TextFiles[fileName];
    }
    
}