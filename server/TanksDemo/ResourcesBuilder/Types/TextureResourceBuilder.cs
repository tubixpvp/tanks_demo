using System.Text;
using System.Xml.Linq;
using GameResources;

namespace ResourcesBuilder.Types;

internal class TextureResourceBuilder : ResourceTypeBuilderBase
{
    private static readonly string[] DiffuseFileNames = ["texture","image"];
    private static readonly string[] AlphaFileNames = ["alpha"];
    
    private static readonly string[] FileExtensions = ["png", "jpg", "jpeg", "gif"];
    
    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        outputFiles["texture.jpg"] = await LoadFirst(resourceInfo.FilesPath, DiffuseFileNames, FileExtensions)
                                     ?? throw new Exception("No texture found: " + resourceInfo.FilesPath);

        byte[]? alphaData = await LoadFirst(resourceInfo.FilesPath, AlphaFileNames, FileExtensions);

        if (alphaData != null)
        {
            outputFiles["alpha.gif"] = alphaData;
        }
        
        outputFiles["texture.xml"] = Encoding.UTF8.GetBytes(new XElement("texture",
            new XAttribute("alpha", (alphaData != null).ToString().ToLower())
        ).ToString());

        return string.Empty;
    }
    
}