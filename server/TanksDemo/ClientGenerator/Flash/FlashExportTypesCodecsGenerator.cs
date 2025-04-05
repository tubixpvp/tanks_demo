using System.Reflection;
using Core.Generator;
using Newtonsoft.Json;
using ProtocolEncoding;
using Utils;

namespace ClientGenerator.Flash;

internal class FlashExportTypesCodecsGenerator : IClientDataGenerator
{
    public async Task Generate(string baseSrcRoot)
    {
        Type[] exportTypes = AttributesUtil.GetTypesWithAttribute(typeof(ClientExportAttribute));

        exportTypes = exportTypes
            .Where(type => type.GetCustomAttribute<ClientExportAttribute>()!.GenerateCodec)
            .ToArray();

        string codecsSrcRoot = Path.Combine(baseSrcRoot, "codecs");
        
        await Task.WhenAll(exportTypes.Select(type => GenerateCodec(type, codecsSrcRoot)));

        await GenerateCodecsActivator(codecsSrcRoot, exportTypes);

        await WriteManifest(baseSrcRoot);
    }

    private async Task WriteManifest(string baseSrcRoot)
    {
        string filePath =Path.Combine(baseSrcRoot, "manifest.json");

        await File.WriteAllTextAsync(filePath, JsonConvert.SerializeObject(new
        {
            activator = "codecs.osgi.CodecsActivator"
        }));
    }

    private async Task GenerateCodecsActivator(string baseSrcRoot, Type[] exportTypes)
    {
        string className = "CodecsActivator";
        string classPackage = "codecs.osgi";
        
        string fileDir = Path.Combine(baseSrcRoot, FlashGenerationUtils.GetDirectoryByNamespace(classPackage));
        
        if (!Directory.Exists(fileDir))
            Directory.CreateDirectory(fileDir);
        
        string filePath = Path.Combine(fileDir, className + ".as");

        
        FlashCodeGenerator generator = new FlashCodeGenerator(classPackage, [
            "alternativa.osgi.bundle.IBundleActivator",
            "alternativa.protocol.factory.ICodecFactory",
            "alternativa.init.OSGi",
            "alternativa.init.Main"
        ]);
        
        generator.AddLine("public class CodecsActivator implements IBundleActivator");
        
        generator.OpenCurvedBrackets();
        //class content:
        
        generator.AddLine("public function start(osgi:OSGi) : void");
        generator.OpenCurvedBrackets();
        //start func:
        
        generator.AddLine("var codecFactory:ICodecFactory = Main.codecFactory;");

        foreach (Type exportType in exportTypes)
        {
            generator.AddLine($"codecFactory.registerCodec({exportType.Name}, new Codec{exportType.Name}());");
            
            generator.AddImport(exportType);
            
            ClientExportAttribute exportAttribute = exportType.GetCustomAttribute<ClientExportAttribute>()!;
            
            string package = exportAttribute.CustomPackage ?? exportType.Namespace!.ToLower();

            generator.AddImport(package + ".Codec" + exportType.Name);
        }
        
        generator.CloseCurvedBrackets(); //start func end
        
        
        generator.AddLine("public function stop(osgi:OSGi) : void");
        generator.OpenCurvedBrackets();
        generator.CloseCurvedBrackets();
        
        
        generator.CloseCurvedBrackets(); //class content end
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private async Task GenerateCodec(Type type, string codecsSrcRoot)
    {
        string fileDir = Path.Combine(codecsSrcRoot, FlashGenerationUtils.GetDirectoryByNamespace(type.Namespace!));
        
        if (!Directory.Exists(fileDir))
        {
            Directory.CreateDirectory(fileDir);
        }

        string className = "Codec"+type.Name;
        
        string filePath = Path.Combine(fileDir, className + ".as");

        string packageName = type.Namespace!.ToLower();

        FlashCodeGenerator generator = new FlashCodeGenerator(packageName, [
            "flash.utils.IDataOutput",
            "flash.utils.IDataInput",
            "alternativa.protocol.codec.NullMap",
            "alternativa.protocol.codec.AbstractCodec",
            "alternativa.protocol.codec.ICodec",
            "alternativa.protocol.factory.ICodecFactory",
            "alternativa.init.Main"
        ]);
        generator.AddImport(type);
        
        generator.AddLine($"public class {className} extends AbstractCodec");
        
        generator.OpenCurvedBrackets();
        generator.AddEmptyLine();
        //class content:
        
        generator.AddLine("private const codecFactory:ICodecFactory = Main.codecFactory;");
        generator.AddEmptyLine();

        generator.AddLine("protected override function doDecode(dataInput:IDataInput, nullMap:NullMap, notnull:Boolean):Object");
        generator.OpenCurvedBrackets();
        //decoding func:
        if (type.IsEnum)
        {
            GenerateEnumDecoder(type, generator);
        }
        else
        {
            GenerateClassEncoder(type, generator, false);
        }
        generator.CloseCurvedBrackets(); //end of decoding func
        generator.AddEmptyLine();
        
        generator.AddLine("protected override function doEncode(dest:IDataOutput, object:Object, nullMap:NullMap, notnull:Boolean):void");
        generator.OpenCurvedBrackets();
        //encoding func:
        if (type.IsEnum)
        {
            GenerateEnumEncoder(type, generator);
        }
        else
        {
            GenerateClassEncoder(type, generator, true);
        }
        generator.CloseCurvedBrackets(); //end of encoding func
        
        
        generator.CloseCurvedBrackets(); //class content end
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private void GenerateEnumDecoder(Type type, FlashCodeGenerator generator)
    {
        Type enumBaseType = Enum.GetUnderlyingType(type);
        
        generator.AddLine("var codec:ICodec = " + FlashGenerationUtils.MakeGetCodecCodeFragment(enumBaseType, generator));
        
        generator.AddLine($"var index:{FlashCodeGenerator.GetFlashDeclarationTypeString(enumBaseType)} = {FlashGenerationUtils.MakeTypeDecodeCodeFragment(enumBaseType, false)}");
        
        generator.AddLine($"for each(var item:{type.Name} in {type.Name}.ENUM_VALUES)");
        generator.OpenCurvedBrackets();
        //foreach:
        
        generator.AddLine("if (item.value == index)");
        generator.OpenCurvedBrackets();
        //if:
        generator.AddLine("return item;");
        generator.CloseCurvedBrackets(); //end of if
        
        generator.CloseCurvedBrackets(); //end of foreach
        
        generator.AddLine("throw new Error(\"Enum element with index not exists: \" + index);");
    }

    private void GenerateEnumEncoder(Type type, FlashCodeGenerator generator)
    {
        Type enumBaseType = Enum.GetUnderlyingType(type);
        
        generator.AddLine("var codec:ICodec = " + FlashGenerationUtils.MakeGetCodecCodeFragment(enumBaseType, generator));
        
        generator.AddLine(FlashGenerationUtils.MakeTypeEncodeCodeFragment(false, "object.value"));
    }

    private void GenerateClassEncoder(Type type, FlashCodeGenerator generator, bool encoding)
    {
        if (encoding)
        {
            generator.AddLine($"var data:{type.Name} = object as {type.Name};");
        }
        else
        {
            generator.AddLine($"var data:{type.Name} = new {type.Name}();");
        }

        generator.AddLine("var codec:ICodec;");

        FieldInfo[] fields = type.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.DeclaredOnly);

        Type? previousCodecType = null;
        
        foreach (FieldInfo fieldInfo in fields)
        {
            if (fieldInfo.GetCustomAttribute<ProtocolIgnoreAttribute>() != null)
                continue;
            
            Type fieldType = fieldInfo.FieldType;
            Type? underlyingType = Nullable.GetUnderlyingType(fieldType);
            bool optional = underlyingType != null;
            if (underlyingType != null)
                fieldType = underlyingType;
            
            if (previousCodecType != fieldType)
            {
                previousCodecType = fieldType;

                generator.AddLine("codec = " + FlashGenerationUtils.MakeGetCodecCodeFragment(fieldType, generator));
            }

            string paramName = FlashGenerationUtils.FirstLetterToLower(fieldInfo.Name);

            if (encoding)
            {
                generator.AddLine(FlashGenerationUtils.MakeTypeEncodeCodeFragment(optional, "data." + paramName));
            }
            else
            {
                generator.AddLine($"data.{paramName} = " +
                                  FlashGenerationUtils.MakeTypeDecodeCodeFragment(fieldType, optional));
            }
        }

        if (!encoding)
        {
            generator.AddLine("return data;");
        }
    }
}