using GameResources;

namespace ResourcesBuilder.Types;

internal class A3DResourceBuilder : ResourceTypeBuilderBase
{
    private static readonly string[] FileNames = ["model", "object"];
    
    private static readonly string[] FileExtensionsA3D = ["a3d"];
    private static readonly string[] FileExtensions3DS = ["3ds"];


    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        byte[]? data3ds = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensions3DS);

        string format;
        if (data3ds != null)
        {
            outputFiles["object.3ds"] = data3ds;
            format = "3ds";

            await CollectTextures(resourceFiles, outputFiles);
        }
        else
        {
            byte[] dataA3d = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensionsA3D)
                             ?? throw new Exception("Model 3d file not found in: " + resourceInfo.FilesPath);
            outputFiles["object.a3d"] = dataA3d;
            format = "a3d";
        }

        return format;
    }

    private async Task CollectTextures(string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        foreach (string filePath in resourceFiles)
        {
            string extension = Path.GetExtension(filePath).ToLower().Replace(".", string.Empty);

            if (TextureResourceBuilder.FileExtensions.Contains(extension))
            {
                outputFiles[Path.GetFileName(filePath)] = await File.ReadAllBytesAsync(filePath);
            }
        }
    }
    
}