using System.Reflection;
using Core.GameObjects;
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

        if (modelType.GetCustomAttribute<ModelAttribute>()!.ServerOnly)
            return;

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
            "alternativa.model.IModel",
            "alternativa.protocol.codec.ICodec",
            "flash.utils.ByteArray",
            "alternativa.network.command.SpaceCommand",
            "alternativa.init.Main"
        ]);
        
        generator.AddImport(typeof(GameObject));
        generator.AddImport(typeof(long));
        
        generator.AddLine($"public class {className} implements IModel");
        
        generator.OpenCurvedBrackets();
        generator.AddEmptyLine();
        
        //class contents
        generator.AddLine($"private var client:I{className};");
        generator.AddEmptyLine();
        
        
        generator.AddLine("private const sendBuffer:ByteArray = new ByteArray();");
        
        
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
        MethodInfo[] netMethods = ModelUtils.GetServerInterfaceMethods(model.GetType());
        //Dictionary<long, MethodInfo> netMethods = model.GetServerInterfaceMethods();

        foreach (MethodInfo methodInfo in netMethods)
        {
            generator.AddEmptyLine();

            long methodId = ModelRegistry.GetMethodId(methodInfo);
            
            GenerateModelServerInterfaceMethod(methodInfo, methodId, generator);
        }
    }

    private void GenerateModelServerInterfaceMethod(MethodInfo methodInfo, long methodId, FlashCodeGenerator generator)
    {
        generator.AddLine("protected " + GenerateFunctionDeclaration(methodInfo, generator));
        
        generator.OpenCurvedBrackets();
        
        generator.AddLine("sendBuffer.clear();");
        generator.AddLine("var nullMap:NullMap = new NullMap();");
        
        ParameterInfo[] parameters = methodInfo.GetParameters();
        
        generator.AddLine("var codecFactory:ICodecFactory = Main.codecFactory;");
        generator.AddLine("var codec:ICodec;");

        Type? previousParamType = null;
        
        foreach(ParameterInfo parameter in parameters)
        {
            Type parameterType = parameter.ParameterType;
            
            Type? underlyingType = Nullable.GetUnderlyingType(parameterType);
            bool optional = underlyingType != null;
            if (underlyingType != null)
                parameterType = underlyingType;

            if (previousParamType != parameterType)
            {
                previousParamType = parameterType;
                
                generator.AddLine("codec = " + FlashGenerationUtils.MakeGetCodecCodeFragment(parameterType, generator));
            }
            
            generator.AddLine(FlashGenerationUtils.MakeTypeEncodeCodeFragment(optional, parameter.Name!, "sendBuffer"));
        }
        
        (long methodIdHigh, long methodIdLow) = LongUtils.GetLongHighLow(methodId);
        
        generator.AddLine($"var command:SpaceCommand = new SpaceCommand(clientObject.id, LongFactory.getLong({methodIdHigh}, {methodIdLow}), sendBuffer, nullMap);");
        generator.AddLine("clientObject.handler.commandSender.sendCommand(command);");
        
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
        MethodInfo? initMethodInfo = clientInterfaceType.GetMethod(ModelUtils.InitObjectFunc);
        
        generator.AddLine("public function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void");
        generator.OpenCurvedBrackets();

        if (initMethodInfo != null)
        {
            ParameterInfo[] initFuncParams = initMethodInfo.GetParameters();

            generator.AddLine("var codec:ICodec;");

            Type? previousCodecType = null;

            foreach (ParameterInfo paramInfo in initFuncParams)
            {
                Type fieldType = paramInfo.ParameterType;
                Type? underlyingType = Nullable.GetUnderlyingType(fieldType);
                bool optional = underlyingType != null;
                if (underlyingType != null)
                    fieldType = underlyingType;

                //set codec:
                if (previousCodecType != fieldType)
                {
                    previousCodecType = fieldType;

                    generator.AddLine("codec = " + FlashGenerationUtils.MakeGetCodecCodeFragment(fieldType, generator));
                }

                //decode:
                generator.AddLine($"var {paramInfo.Name}:{FlashCodeGenerator.GetFlashDeclarationTypeString(fieldType)} = " + FlashGenerationUtils.MakeTypeDecodeCodeFragment(fieldType, optional));
            }

            string callLine = "client.initObject(clientObject, ";

            callLine += string.Join(", ", initFuncParams.Select(funcParam => funcParam.Name));

            generator.AddLine(callLine + ");");
        }

        generator.CloseCurvedBrackets();
    }


    private async Task GenerateModelClientInterface(IModel model, string fileDir, string modelName, string packageName)
    {
        string className = "I" + modelName + "Base";
        string filePath = Path.Combine(fileDir, className + ".as");
        
        Type clientInterfaceType = model.GetClientInterfaceType();
        
        
        FlashCodeGenerator generator = new FlashCodeGenerator(packageName);
        
        generator.AddImport(typeof(GameObject));
        
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
        string functionStr = $"function {FlashGenerationUtils.FirstLetterToLower(methodInfo.Name)}(clientObject:ClientObject";

        ParameterInfo[] parameters = methodInfo.GetParameters();

        foreach (ParameterInfo parameter in parameters)
        {
            functionStr += ", " + parameter.Name + ":" + FlashCodeGenerator.GetFlashDeclarationTypeString(parameter.ParameterType);

            if (parameter.ParameterType.IsArray)
            {
                generator.AddImport(parameter.ParameterType.GetElementType()!);
                continue;
            }
            generator.AddImport(parameter.ParameterType);
        }

        functionStr += "):void";
        return functionStr;
    }
    
}