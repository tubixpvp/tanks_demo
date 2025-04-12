using GameResources;

namespace ResourcesBuilder.Types;

internal class A3DCollisionResourceBuilder : ResourceTypeBuilderBase
{
    private static readonly string[] FileNames = ["collision","collisions"];
    private static readonly string[] FileExtensions = ["a3dc"];
    
    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        outputFiles["collisions.a3dc"] = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensions)
                            ?? throw new Exception("Collision data not found in: " + resourceInfo.FilesPath);

        return string.Empty;
    }
    
}