using ClientGenerator.Flash;
using Config;
using Core.Model.Registry;
using OSGI.Services;
using Logging;
using Newtonsoft.Json;
using Utils;

namespace ClientGenerator;

internal class ClientDataGeneratorRunner
{
    [InjectService]
    private static LoggerService LoggerService;
    
    
    private static readonly IClientDataGenerator[] Generators = 
    [
        new FlashModelBaseGenerator(),
        new FlashExportTypesGenerator(),
        new FlashExportTypesCodecsGenerator()
    ];

    private static readonly FlashActivatorGenerator _flashActivatorGenerator = new();
    
    public static void Main(string[] args)
    {
        ParametersUtil runParams = ParametersUtil.FromRunArguments(args);

        _ = new ClientDataGeneratorRunner(runParams);
    }


    private ClientDataGeneratorRunner(ParametersUtil runParams)
    {
        ServerLaunchParams.Init(runParams);
        
        ServerResources.Init();
        
        string? clientSrcRoot = runParams.GetString("client_src");

        if (clientSrcRoot == null)
        {
            throw new Exception("Client src root is required");
        }

        clientSrcRoot = Path.GetFullPath(clientSrcRoot);
        
        
        OSGi.Init();
        OSGi.GetService<ModelRegistry>().Init();
        
        
        ILogger logger = LoggerService.GetLogger(typeof(ClientDataGeneratorRunner));
        
        logger.Log(LogLevel.Info, "Starting client generator");
        
        string baseSrcRoot = Path.Combine(clientSrcRoot, "base");

        //clean the folder
        if (Directory.Exists(baseSrcRoot))
        {
            Directory.Delete(baseSrcRoot, true);
        }
        Directory.CreateDirectory(baseSrcRoot);

        logger.Log(LogLevel.Info, "Working in directory: " + baseSrcRoot);
        
        Task.WaitAll(Generators.Select(generator => generator.Generate(baseSrcRoot)));

        SafeTask.AddListeners(_flashActivatorGenerator.Generate(baseSrcRoot, Generators), null).Wait();
        
        logger.Log(LogLevel.Info, "Client generator finished");
    }
    
}