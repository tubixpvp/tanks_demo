using System.Reflection;
using Core.Generator;
using Utils;

namespace ClientGenerator.Flash;

internal class FlashExportTypesGenerator : IClientDataGenerator
{
    public async Task Generate(string baseSrcRoot)
    {
        Type[] types = AttributesUtil.GetTypesWithAttribute(typeof(ClientExportAttribute));

        await Task.WhenAll(types
            .Where(type => type.GetCustomAttribute<ClientExportAttribute>()!.GenerateCodec)
            .Select(type => GenerateTypeFile(type, baseSrcRoot)));
    }

    private async Task GenerateTypeFile(Type type, string baseSrcRoot)
    {
        string fileDir = Path.Combine(baseSrcRoot, FlashGenerationUtils.GetDirectoryByNamespace(type.Namespace!));
        
        if (!Directory.Exists(fileDir))
        {
            Directory.CreateDirectory(fileDir);
        }
        
        string filePath = Path.Combine(fileDir, type.Name + ".as");

        string packageName = type.Namespace!.ToLower();

        FlashCodeGenerator generator = new FlashCodeGenerator(packageName);
        
        generator.AddLine("public class " + type.Name);
        
        generator.OpenCurvedBrackets();
        //class contents:

        if (type.IsEnum)
        {
            GenerateEnum(type, generator);
        }
        
        generator.CloseCurvedBrackets(); //class contents end
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private void GenerateEnum(Type type, FlashCodeGenerator generator)
    {
        string[] keys = type.GetEnumNames();
        Array values = type.GetEnumValuesAsUnderlyingType();

        for (int i = 0; i < keys.Length; i++)
        {
            generator.AddLine($"public static const {GetFlashKeyName(keys[i])}:{type.Name} = new {type.Name}({values.GetValue(i)});");
            generator.AddEmptyLine();
        }

        Type underlyingType = Enum.GetUnderlyingType(type);
        generator.AddImport(underlyingType);
        
        string valueType = FlashCodeGenerator.GetFlashDeclarationTypeName(underlyingType);
        
        generator.AddLine($"public var value:{valueType};");
        generator.AddEmptyLine();
        
        generator.AddLine($"public function LayerModelEnum(value:{valueType})");
        
        generator.OpenCurvedBrackets();
        generator.AddLine("this.value = value;");
        generator.CloseCurvedBrackets();

        return;

        static string GetFlashKeyName(string name)
        {
            string result = string.Empty;

            foreach (char c in name)
            {
                if (char.IsUpper(c)              //upper
                    && result != string.Empty && //but not first entry
                    !char.IsUpper(result[^1]))   //and last entry wasn't upper too
                {
                    result += "_";
                }
                result += c;
            }

            return result.ToUpper();
        }
    }
    
    
}