using System.Reflection;
using Logging;
using Newtonsoft.Json.Linq;
using Utils;

namespace Config;

public static class ServerResources
{
    private const string ResourcesFolder = "Resources";

    private static readonly ILogger Logger = new LoggerService().GetLogger(typeof(ServerResources));

    private static readonly Dictionary<string, JObject> Configs = new();

    private static readonly Dictionary<string, string> TextFiles = new();
    
    public static void Init()
    {
        string binFolder = Path.GetDirectoryName(Assembly.GetEntryAssembly()!.Location)!;
        string configsRoot = Path.Combine(binFolder, ResourcesFolder);
        
        Logger.Log(LogLevel.Info, 
            $"Loading configs from {configsRoot}");

        string[] configsPaths = Directory.GetFiles(configsRoot, "*.json", SearchOption.AllDirectories);

        foreach (string configPath in configsPaths)
        {
            JObject json = JSON.ParseObject(File.ReadAllText(configPath));
            
            string fileName = Path.GetFileName(configPath);
            
            Configs.Add(fileName, json);
        }
        
        
        string[] otherConfigsPaths = Directory.GetFiles(configsRoot, "*", SearchOption.AllDirectories);

        foreach (string configPath in otherConfigsPaths.Except(configsPaths))
        {
            //string fileName = Path.GetFileName(configPath);
            string fileLocalPath = Path.GetRelativePath(configsRoot, configPath).Replace('\\','/');
            
            string text = File.ReadAllText(configPath);
            
            TextFiles.Add(fileLocalPath, text);
        }
    }

    public static T GetConfig<T>(string fileName)
    {
        return Configs[fileName].ToObject<T>()!;
    }

    public static string GetTextData(string fileLocalPath)
    {
        return TextFiles[fileLocalPath];
    }
    
}