using System.Reflection;
using Core.GameObject;
using Core.Model;
using Core.Model.Registry;
using OSGI.Services;
using Utils;

namespace ClientGenerator.Flash;

internal class FlashModelBaseGenerator : IClientDataGenerator
{
    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    
    public async Task Generate(string baseSrcRoot)
    {
        IModel[] models = ModelRegistry.GetAllModels();

        await Task.WhenAll(models.Select(
            model => GenerateModelBaseFiles(model, baseSrcRoot)));
    }

    private async Task GenerateModelBaseFiles(IModel model, string baseSrcRoot)
    {
        Type modelType = model.GetType();

        string packageName = modelType.Namespace!.ToLower();
        string fileDir = Path.Combine(baseSrcRoot, FlashGenerationUtils.GetDirectoryByNamespace(modelType.Namespace!));

        if (!Directory.Exists(fileDir))
        {
            Directory.CreateDirectory(fileDir);
        }
        
        await GenerateModelBase(model, fileDir, modelType.Name, packageName);
        await GenerateModelClientInterface(model, fileDir, modelType.Name, packageName);
    }

    private async Task GenerateModelBase(IModel model, string fileDir, string modelName, string packageName)
    {
        string className = modelName + "Base";
        string filePath = Path.Combine(fileDir, className + ".as");
        
        Type clientInterfaceType = model.GetClientInterfaceType();

        FlashCodeGenerator generator = new FlashCodeGenerator(packageName, 
        [
            "alternativa.types.LongFactory",
            "alternativa.protocol.factory.ICodecFactory",
            "flash.utils.IDataInput",
            "alternativa.protocol.codec.NullMap",
            "alternativa.model.IModel"
        ]);
        
        generator.AddImport(typeof(ClientObject));
        generator.AddImport(typeof(long));
        
        generator.AddLine($"public class {className} implements IModel");
        
        generator.OpenCurvedBrackets();
        generator.AddEmptyLine();
        
        //class contents
        generator.AddLine($"private var client:I{className};");
        generator.AddEmptyLine();
        
        generator.AddLine($"public function {className}()");
        generator.OpenCurvedBrackets();
        //constructor
        
        generator.AddLine($"client = I{className}(this);");
        
        generator.CloseCurvedBrackets(); //constructor end
        generator.AddEmptyLine();
        
        
        generator.AddLine("public function get id():Long");
        generator.OpenCurvedBrackets();
        //id getter
        (int idHigh, int idLow) = LongUtils.GetLongHighLow(model.Id);
        
        generator.AddLine($"return LongFactory.getLong({idHigh},{idLow});");
        
        generator.CloseCurvedBrackets(); //id getter end
        generator.AddEmptyLine();
        
        GenerateInitObjectFunction(generator, clientInterfaceType);
        generator.AddEmptyLine();
        
        GenerateInvokeFunction(generator, clientInterfaceType);

        GenerateModelServerInterfaceMethods(model, generator);
        
        generator.AddEmptyLine();
        generator.CloseCurvedBrackets(); //class contents end

        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private void GenerateModelServerInterfaceMethods(IModel model, FlashCodeGenerator generator)
    {
        Dictionary<byte, MethodInfo> netMethods = model.GetServerInterfaceMethods();

        foreach ((byte methodId, MethodInfo methodInfo) in netMethods)
        {
            generator.AddEmptyLine();
            
            GenerateModelServerInterfaceMethod(methodInfo, methodId, generator);
        }
    }

    private void GenerateModelServerInterfaceMethod(MethodInfo methodInfo, byte methodId, FlashCodeGenerator generator)
    {
        generator.AddLine("protected " + GenerateFunctionDeclaration(methodInfo, generator));
        
        generator.OpenCurvedBrackets();
        
        //todo
        
        generator.CloseCurvedBrackets();
    }

    private void GenerateInvokeFunction(FlashCodeGenerator generator, Type clientInterfaceType)
    {
        generator.AddLine("public function invoke(clientObject:ClientObject, methodId:Long, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void");
        generator.OpenCurvedBrackets();
        
        //todo
        
        generator.CloseCurvedBrackets();
    }

    private void GenerateInitObjectFunction(FlashCodeGenerator generator, Type clientInterfaceType)
    {
        generator.AddLine("public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void");
        generator.OpenCurvedBrackets();
        
        //todo
        
        generator.CloseCurvedBrackets();
    }


    private async Task GenerateModelClientInterface(IModel model, string fileDir, string modelName, string packageName)
    {
        string className = "I" + modelName + "Base";
        string filePath = Path.Combine(fileDir, className + ".as");
        
        Type clientInterfaceType = model.GetClientInterfaceType();
        
        //remove constructor
        //methods = methods.Where(method => method.Name != "InitObject").ToArray();
        
        
        FlashCodeGenerator generator = new FlashCodeGenerator(packageName);
        
        generator.AddImport(typeof(ClientObject));
        
        generator.AddLine($"public interface {className}");
        
        generator.OpenCurvedBrackets();
        //interface contents:

        if (clientInterfaceType != typeof(object)) //object -> model doesn't have CI
        {
            MethodInfo[] methods = clientInterfaceType.GetMethods(BindingFlags.Instance | BindingFlags.Public);

            foreach (MethodInfo methodInfo in methods)
            {
                generator.AddEmptyLine();

                generator.AddLine(GenerateFunctionDeclaration(methodInfo, generator) + ";");
            }
        }

        generator.CloseCurvedBrackets(); //interface contents end
        
        
        await File.WriteAllTextAsync(filePath, generator.GetResult());
    }

    private string GenerateFunctionDeclaration(MethodInfo methodInfo, FlashCodeGenerator generator)
    {
        string functionStr = $"function {FirstLetterToLower(methodInfo.Name)}(object:ClientObject";

        ParameterInfo[] parameters = methodInfo.GetParameters();

        foreach (ParameterInfo parameter in parameters)
        {
            functionStr += ", " + parameter.Name + ":" + FlashCodeGenerator.GetFlashDeclarationTypeName(parameter.ParameterType);

            generator.AddImport(parameter.ParameterType);
        }

        functionStr += "):void";
        return functionStr;
    }

    private async Task GenerateModelBaseServer(IModel model, string fileDir, string modelName)
    {
        string filePath = Path.Combine(fileDir, modelName + "BaseServer.as");
        
    }

    private static string FirstLetterToLower(string str)
    {
        return str[0].ToString().ToLower() + str.Substring(1);
    }
}