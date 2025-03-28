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

        if (type.BaseType != null && type.BaseType != typeof(object) && type.BaseType != typeof(Enum))
        {
            generator.AddLine($"public class {type.Name} extends {type.BaseType.Name}");

            generator.AddImport(type.BaseType);
        }
        else
        {
            generator.AddLine("public class " + type.Name);
        }

        generator.OpenCurvedBrackets();
        //class contents:

        if (type.IsEnum)
        {
            GenerateEnum(type, generator);
        }
        else
        {
            GenerateTypeFields(type, generator);
        }
        
        generator.CloseCurvedBrackets(); //class contents end
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private void GenerateTypeFields(Type type, FlashCodeGenerator generator)
    {
        FieldInfo[] fields = type.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.DeclaredOnly);

        foreach (FieldInfo fieldInfo in fields)
        {
            Type fieldType = fieldInfo.FieldType;
            fieldType = Nullable.GetUnderlyingType(fieldType) ?? fieldType;
            
            generator.AddLine($"public var {FirstLetterToLower(fieldInfo.Name)}:{FlashCodeGenerator.GetFlashDeclarationTypeString(fieldType)};");
            generator.AddEmptyLine();

            if (fieldType.IsArray)
            {
                generator.AddImport(fieldType.GetElementType()!);
                continue;
            }
            generator.AddImport(fieldType);
        }
    }

    private static string FirstLetterToLower(string str)
    {
        return str.Substring(0, 1).ToLower() + str.Substring(1);
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
        
        string valueType = FlashCodeGenerator.GetFlashDeclarationTypeString(underlyingType);
        
        generator.AddLine($"public var value:{valueType};");
        generator.AddEmptyLine();
        
        generator.AddLine($"public function {type.Name}(value:{valueType})");
        
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