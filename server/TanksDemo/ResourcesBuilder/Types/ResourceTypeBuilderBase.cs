using GameResources;

namespace ResourcesBuilder.Types;

internal abstract class ResourceTypeBuilderBase
{
    
    public abstract Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles);

    protected async Task<byte[]?> LoadFirst(string rootDir, string[] fileNames, string[] fileExtensions)
    {
        foreach (string fileName in fileNames)
        {
            string filePathWithoutExtension = Path.Combine(rootDir, fileName);

            foreach (string fileExtension in fileExtensions)
            {
                string filePath = filePathWithoutExtension + '.' + fileExtension;

                if (File.Exists(filePath))
                {
                    return await File.ReadAllBytesAsync(filePath);
                }
            }
        }
        return null;
    }
    
}