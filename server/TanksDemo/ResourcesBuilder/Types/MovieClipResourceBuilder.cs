using GameResources;

namespace ResourcesBuilder.Types;

internal class MovieClipResourceBuilder : ResourceTypeBuilderBase
{
    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        outputFiles["mc.swf"] = await File.ReadAllBytesAsync(Path.Combine(resourceInfo.FilesPath, "mc.swf"));

        return string.Empty;
    }
}