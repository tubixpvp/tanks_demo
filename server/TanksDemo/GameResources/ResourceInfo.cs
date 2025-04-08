namespace GameResources;

public class ResourceInfo
{
    public required string Id { get; init; }
    public required long NumericId { get; init; }
    public required ResourceType Type { get; init; }
    
    public required string FilesPath { get; init; }
}