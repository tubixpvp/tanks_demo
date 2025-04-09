using System.Reflection;
using Config;
using Newtonsoft.Json;
using OSGI.Services;

namespace GameResources;

[Service]
public class ResourceRegistry : IOSGiInitListener
{
    public const string ResourceInfoFile = "info.json";
    
    
    private static readonly Random Random = new();
    
    
    private readonly string _resourcesCacheDir;
    
    
    private readonly Dictionary<string, ResourceInfo> _resources = new();
    
    private ResourceInfo[] _resourcesArray;
    
    
    public ResourceRegistry()
    {
        _resourcesCacheDir = ServerLaunchParams.GetLaunchParams().GetString("resCacheDir") ?? throw new Exception("Resources cache directory is not provided");
        _resourcesCacheDir = Path.GetFullPath(_resourcesCacheDir);
    }
    
    public void OnOSGiInited()
    {
        if (!Directory.Exists(_resourcesCacheDir))
        {
            Directory.CreateDirectory(_resourcesCacheDir);
        }
        
        string appRootPath = Path.GetDirectoryName(Assembly.GetEntryAssembly()!.Location)!;
        string resourcesPath = Path.Combine(appRootPath, "Resources/Game");

        string[] resourceInfoFiles = Directory.GetFiles(resourcesPath, ResourceInfoFile, SearchOption.AllDirectories);

        foreach (string resourceInfoPath in resourceInfoFiles)
        {
            string resourceRootDir = Path.GetDirectoryName(resourceInfoPath)!;
            
            ResourceInfoJson json = JsonConvert.DeserializeObject<ResourceInfoJson>(
                File.ReadAllText(resourceInfoPath))!;

            ResourceFilesCache cache = LoadResourceCache(json.Id).GetAwaiter().GetResult();
            
            _resources.Add(json.Id, new ResourceInfo()
            {
                Id = json.Id,
                Type = json.Type,
                FilesPath = resourceRootDir,
                DependenciesIds = json.Dependencies ?? [],
                Cache = cache
            });
        }
        
        _resourcesArray = _resources.Values.ToArray();
    }

    private async Task<ResourceFilesCache> LoadResourceCache(string resourceId)
    {
        string path = Path.Combine(_resourcesCacheDir, resourceId + ".json");
        
        if (File.Exists(path))
        {
            return JsonConvert.DeserializeObject<ResourceFilesCache>(await File.ReadAllTextAsync(path))!;
        }

        ResourceFilesCache cache = new ResourceFilesCache()
        {
            NumericId = Random.NextInt64(long.MinValue,long.MaxValue),
            Version = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            Hashes = new Dictionary<string, string>()
        };

        await SaveResourceCache(resourceId, cache);

        return cache;
    }
    public async Task SaveResourceCache(string resourceId, ResourceFilesCache cache)
    {
        string path = Path.Combine(_resourcesCacheDir, resourceId +".json");
        
        await File.WriteAllTextAsync(path, JsonConvert.SerializeObject(cache));
    }

    public ResourceInfo GetResourceInfo(string id)
    {
        return _resources[id];
    }
    public long GetNumericId(string id)
    {
        return GetResourceInfo(id).NumericId;
    }

    public ResourceInfo[] GetAllResources() => _resourcesArray;

    class ResourceInfoJson
    {
        [JsonProperty("id")]
        public string Id;

        [JsonProperty("type")]
        public ResourceType Type;

        [JsonProperty("description")]
        public string Description;

        [JsonProperty("dependencies")]
        public string[]? Dependencies;
    }
}