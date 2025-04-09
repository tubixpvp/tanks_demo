namespace GameResources;

public class ResourceInfo
{
    public required string Id { get; init; }
    public required ResourceType Type { get; init; }
    
    public required string[] DependenciesIds { get; init; }
    
    public required string FilesPath { get; init; }
    
    
    public long NumericId => Cache.NumericId;
    public long NumericVersion => Cache.Version;
    
    public required ResourceFilesCache Cache { get; init; }
}