using System.Text;
using System.Xml.Linq;
using GameResources;

namespace ResourcesBuilder.Types;

internal class TextureResourceBuilder : ResourceTypeBuilderBase
{
    private static readonly string[] DiffuseFileNames = [
        "texture.png", "texture.jpg", "texture.gif"
    ];
    private static readonly string[] AlphaFileNames = [
        "alpha.png", "alpha.jpg", "alpha.gif"
    ];
    
    private static readonly string[] FileExtensions = ["png", "jpg", "gif"];
    
    public override async Task CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        outputFiles["texture.jpg"] = await LoadFirstWithName(resourceInfo.FilesPath, DiffuseFileNames)
                                     ?? await LoadFirstWithExtension(resourceFiles, FileExtensions)
                                     ?? throw new Exception("No texture found: " + resourceInfo.FilesPath);

        byte[]? alphaData = await LoadFirstWithName(resourceInfo.FilesPath, AlphaFileNames);

        if (alphaData != null)
        {
            outputFiles["alpha.gif"] = alphaData;
        }
        
        outputFiles["texture.xml"] = Encoding.UTF8.GetBytes(new XElement("texture",
            new XAttribute("alpha", (alphaData != null).ToString().ToLower())
        ).ToString());
    }
    
}