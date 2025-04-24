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

        string[] configsPaths = Directory.GetFiles(configsRoot, "*", SearchOption.AllDirectories);

        foreach (string configPath in configsPaths)
        {
            if (Path.GetFileName(configPath) == ".DS_Store") //MacOS hidden system file
                continue;
            
            string fileLocalPath = Path.GetRelativePath(configsRoot, configPath).Replace('\\','/');
            
            string text = File.ReadAllText(configPath);
            
            TextFiles.Add(fileLocalPath, text);

            if (Path.GetExtension(fileLocalPath).ToLower() == ".json")
            {
                JObject json = JSON.ParseObject(text);
                
                Configs.Add(fileLocalPath, json);
            }
        }
    }

    public static T GetConfig<T>(string fileName)
    {
        return Configs[fileName].ToObject<T>()!;
    }

    public static T[] GetConfigsInPath<T>(string relativePath)
    {
        return Configs
            .Where(pair => pair.Key.StartsWith(relativePath))
            .Select(pair => pair.Value.ToObject<T>()!)
            .ToArray();
    }

    public static string GetTextData(string fileLocalPath)
    {
        return TextFiles[fileLocalPath];
    }
    
}