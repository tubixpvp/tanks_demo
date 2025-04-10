using GameResources;
using Logging;
using ResourcesBuilder.Types;
using Utils;

namespace ResourcesBuilder;

internal class GameResourcesBuilder
{
    private static ResourceRegistry ResourceRegistry = new();


    private static readonly Dictionary<ResourceType, ResourceTypeBuilderBase> ResourceTypeBuilders = new()
    {
        [ResourceType.Texture] = new TextureResourceBuilder(),
        [ResourceType.A3D] = new A3DResourceBuilder()
    };


    private readonly ResourceBuilderRunner _resourceBuilder;
    

    private readonly ResourceInfo[] _resources;

    private readonly ILogger _logger;
    
    
    public GameResourcesBuilder(ParametersUtil launchParams, ResourceBuilderRunner resourceBuilder)
    {
        _logger = ResourceBuilderRunner.LoggerService.GetLogger(GetType());
        
        _resourceBuilder = resourceBuilder;
        
        ResourceRegistry.OnOSGiInited(); //init service
        
        _resources = ResourceRegistry.GetAllResources();
    }

    public async Task Build()
    {
        await SafeTask.AddListeners(Task.WhenAll(_resources.Select(BuildResource)), null);
    }

    private async Task BuildResource(ResourceInfo resourceInfo)
    {
        
        _logger.Log(LogLevel.Info, 
            $"Building resource {resourceInfo.Id} from {resourceInfo.FilesPath}");
        
        (Dictionary<string, byte[]> resourceFiles, string resourceName) = await CollectFiles(resourceInfo);

        Dictionary<string, string> resourceHashes = resourceFiles.ToDictionary(
            pair => pair.Key, pair => HashUtil.GetBase64SHA256String(pair.Value));

        ResourceFilesCache resourceCache = resourceInfo.Cache;// await ResourceRegistry.LoadResourceCache(resourceInfo.Id);

        bool changed = false;
        foreach ((string fileName, string fileHash) in resourceHashes)
        {
            if (!resourceCache.Hashes.TryGetValue(fileName, out string? fileOldHash)
                || fileHash != fileOldHash)
            {
                resourceCache.Hashes[fileName] = fileHash;
                changed = true;
            }
        }

        if (changed)
        {
            resourceCache.Version = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            
            await ResourceRegistry.SaveResourceCache(resourceInfo.Id, resourceCache);
        }

        await _resourceBuilder.BuildResource(resourceInfo.NumericId, resourceCache.Version, resourceName, resourceFiles);

    }

    private async Task<(Dictionary<string, byte[]>, string)> CollectFiles(ResourceInfo resourceInfo)
    {
        ResourceTypeBuilderBase typeBuilder = ResourceTypeBuilders[resourceInfo.Type];
        
        string[] files = Directory.GetFiles(resourceInfo.FilesPath, "*", SearchOption.TopDirectoryOnly);

        string resourceInfoPath = Path.Combine(resourceInfo.FilesPath, ResourceRegistry.ResourceInfoFile);

        files = files.Except([resourceInfoPath]).ToArray();

        Dictionary<string, byte[]> resourceFiles = new();

        string resourceName = await typeBuilder.CollectFiles(resourceInfo, files, resourceFiles);

        return (resourceFiles, resourceName);
    }
    
}