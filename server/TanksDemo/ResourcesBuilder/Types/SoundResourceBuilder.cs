using GameResources;

namespace ResourcesBuilder.Types;

internal class SoundResourceBuilder : ResourceTypeBuilderBase
{
    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        outputFiles["sound.mp3"] = await File.ReadAllBytesAsync(Path.Combine(resourceInfo.FilesPath, "sound.mp3"));

        return string.Empty;
    }
}