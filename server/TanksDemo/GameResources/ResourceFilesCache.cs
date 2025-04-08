namespace GameResources;

public class ResourceFilesCache
{
    public long NumericId { get; set; }
        
    public long Version { get; set; }

    public Dictionary<string, string> Hashes { get; set; }
}