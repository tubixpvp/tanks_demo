using Newtonsoft.Json;

namespace ClientGenerator.Flash;

internal class FlashActivatorGenerator
{
    private const string ClassName = "ClientBaseActivator";
    private const string ClassPackage = "osgi";

    public async Task Generate(string baseSrcRoot, IClientDataGenerator[] generators)
    {
        await GenerateActivator(baseSrcRoot, generators);

        await WriteManifest(baseSrcRoot);
    }
    
    private async Task GenerateActivator(string baseSrcRoot, IClientDataGenerator[] codeGenerators)
    {
        string fileDir = Path.Combine(baseSrcRoot, FlashGenerationUtils.GetDirectoryByNamespace(ClassPackage));
        
        if (!Directory.Exists(fileDir))
            Directory.CreateDirectory(fileDir);
        
        string filePath = Path.Combine(fileDir, ClassName + ".as");

        
        FlashCodeGenerator generator = new FlashCodeGenerator(ClassPackage, [
            "alternativa.osgi.bundle.IBundleActivator",
            "alternativa.protocol.factory.ICodecFactory",
            "alternativa.init.OSGi",
            "alternativa.init.Main",
            "alternativa.service.IModelService",
            "alternativa.types.LongFactory"
        ]);
        
        generator.AddLine($"public class {ClassName} implements IBundleActivator");
        
        generator.OpenCurvedBrackets();
        //class content:
        
        generator.AddLine("public function start(osgi:OSGi) : void");
        generator.OpenCurvedBrackets();
        //start func:

        foreach (IClientDataGenerator codeGenerator in codeGenerators)
        {
            codeGenerator.GenerateActivator(generator);
            generator.AddEmptyLine();
        }
        
        generator.CloseCurvedBrackets(); //start func end
        
        
        generator.AddLine("public function stop(osgi:OSGi) : void");
        generator.OpenCurvedBrackets();
        generator.CloseCurvedBrackets();
        
        
        generator.CloseCurvedBrackets(); //class content end
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }
    
    private async Task WriteManifest(string baseSrcRoot)
    {
        string filePath = Path.Combine(baseSrcRoot, "manifest.json");

        await File.WriteAllTextAsync(filePath, JsonConvert.SerializeObject(new
        {
            activator = ClassPackage + "." + ClassName
        }));
    }
    
}