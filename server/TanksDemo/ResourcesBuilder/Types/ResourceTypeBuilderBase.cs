using GameResources;

namespace ResourcesBuilder.Types;

internal abstract class ResourceTypeBuilderBase
{
    
    public abstract Task CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles);



    protected async Task<byte[]?> LoadFirstWithName(string rootDir, string[] fileNames)
    {
        foreach (string fileName in fileNames)
        {
            string filePath = Path.Combine(rootDir, fileName);

            if (File.Exists(filePath))
            {
                return await File.ReadAllBytesAsync(filePath);
            }
        }
        return null;
    }

    protected async Task<byte[]?> LoadFirstWithExtension(string[] files, string[] extensions)
    {
        foreach (string filePath in files)
        {
            string extension = Path.GetExtension(filePath);

            if (extensions.Contains(extension))
            {
                return await File.ReadAllBytesAsync(filePath);
            }
        }
        return null;
    }
    
}