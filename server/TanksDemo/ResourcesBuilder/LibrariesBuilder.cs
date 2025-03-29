using System.IO.Compression;
using System.Text;
using Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Utils;

namespace ResourcesBuilder;

internal class LibrariesBuilder
{
    private const string AlternativaLoaderName = "AlternativaLoader";
    private const string BinaryFolder = "bin";

    private readonly SWFLibrariesDataService LibsDataService = new ();
    
    private readonly ILogger _logger;

    private readonly ResourceBuilderRunner _resourceBuilder;

    private readonly Random _random = new();

    private readonly string _clientRootDir;
    private readonly string _libraryBinariesRoot;

    private readonly string _tasksConfigPath;
    private readonly string _buildClientTaskName;

    private TaskConfigJson[] _tasks;
    
    public LibrariesBuilder(ParametersUtil launchParams, ResourceBuilderRunner resourceBuilder)
    {
        _logger = ResourceBuilderRunner.LoggerService.GetLogger(typeof(LibrariesBuilder));

        _resourceBuilder = resourceBuilder;

        _clientRootDir = Path.GetFullPath(launchParams.GetString("clientDir") ?? throw new Exception("Client root dir is not provided"));
        _libraryBinariesRoot = Path.Combine(_clientRootDir, BinaryFolder);

        _tasksConfigPath = launchParams.GetString("tasks") ?? throw new Exception("No tasks config path provided");
        
        _buildClientTaskName = launchParams.GetString("build_task") ?? throw new Exception("No build client task name provided");
    }

    public async Task Build()
    {
        Dictionary<string, SWFLibraryData> libsData = await LibsDataService.GetLibsData(_clientRootDir);
        
        JObject config = JObject.Parse(await File.ReadAllTextAsync(_tasksConfigPath));
        
        _tasks = config["tasks"]!.ToObject<TaskConfigJson[]>()!;

        TaskConfigJson? clientBuildTask = _tasks.FirstOrDefault(task => task.Label == _buildClientTaskName);

        if (clientBuildTask == null)
            throw new Exception("Build client task is not found in config: " + _buildClientTaskName);

        string[] tasks = clientBuildTask.DependsOn.Where(name => name.StartsWith("Build ")).ToArray();
        tasks = tasks.Except(["Build "+AlternativaLoaderName]).ToArray();
        
        _logger.Log(LogLevel.Info, 
            "Libraries from config: " + string.Join(", ", 
                tasks.Select(task=>task.Substring("Build ".Length))));

        int libIndex = 0;

        //await Task.WhenAll(libs.Select(
        //    libName => BuildLibrary(libName, libIndex++, libsData)));
        foreach (string taskName in tasks)
        {
            await BuildLibrary(taskName, libIndex++, libsData);
        }

        await LibsDataService.WriteLibsData(_clientRootDir, libsData);

        await WriteLoader();
    }

    private async Task WriteLoader()
    {
        string fileName = AlternativaLoaderName + ".swf";
        string filePath = Path.GetFullPath(Path.Combine(_libraryBinariesRoot, fileName));

        _logger.Log(LogLevel.Info, "Building AlternativaLoader: " + filePath);
        
        byte[] data = await File.ReadAllBytesAsync(filePath);

        await _resourceBuilder.WriteFile(fileName, data);
    }

    private async Task BuildLibrary(string taskName, int libIndex, Dictionary<string, SWFLibraryData> libsData)
    {
        TaskConfigJson taskConfig = _tasks.First(task => task.Label == taskName);
        
        string libName = taskName["Build ".Length..];

        string srcPath;
        if (libName == "ClientBase")
        {
            srcPath = "base";
        }
        else
        {
            srcPath = Path.GetDirectoryName(taskConfig.ASConfigPath)!;
            
            if (srcPath.StartsWith("client/"))
            {
                srcPath = srcPath["client/".Length..];
            }
        }
        
        string libraryDir = Path.GetFullPath(Path.Combine(_libraryBinariesRoot, libName));

        _logger.Log(LogLevel.Debug, "Build library " + libraryDir);

        byte[] librarySwcData = await File.ReadAllBytesAsync(Path.Combine(libraryDir, "library.swc"));

        string libHash = HashUtil.GetBase64SHA256String(librarySwcData);
        
        if (!libsData.TryGetValue(libName, out SWFLibraryData? libData))
        {
            libData = new SWFLibraryData()
            {
                ResourceId = _random.Next(10000000,int.MaxValue),
                ResourceVersion = _random.Next(10000000,int.MaxValue),
                LibraryFileHash = libHash
            };
            _logger.Log(LogLevel.Debug, $"Library config for {libName} not exists, created new: {JsonConvert.SerializeObject(libData)}");
            lock (libsData)
            {
                libsData.Add(libName, libData);
            }
        }
        else if(libData.LibraryFileHash != libHash)
        {
            libData.ResourceVersion = _random.Next(10000000, int.MaxValue); //update the version
        }

        byte[] swfData = await GetSwfFromSwc(librarySwcData);

        Dictionary<string, byte[]> resourceData = new()
        {
            [_resourceBuilder.DebugMode?"debug.swf":"library.swf"] = swfData,
            ["MANIFEST.MF"] = Encoding.UTF8.GetBytes(await GetManifest(srcPath, libName))
        };

        //write to file
        await _resourceBuilder.BuildResource(libData.ResourceId, 
            libData.ResourceVersion, 
            libName,
            resourceData);
    }

    private async Task<string> GetManifest(string libSrcPath, string libName)
    {
        libSrcPath = Path.Combine(_clientRootDir, libSrcPath);
        libSrcPath = Path.GetFullPath(libSrcPath);
        
        string manifestPath = Path.Combine(libSrcPath, "manifest.json");

        if (File.Exists(manifestPath))
        {
            JObject manifestJson = JObject.Parse(await File.ReadAllTextAsync(manifestPath));

            string activator = manifestJson["activator"]!.ToObject<string>()!;
            
            return $"Bundle-Name: {libName}\nBundle-Activator: {activator}";
        }

        Console.WriteLine("manifest is missing: " + manifestPath);

        return string.Empty;
    }

    private static async Task<byte[]> GetSwfFromSwc(byte[] swcData)
    {
        using ZipArchive archive = new ZipArchive(new MemoryStream(swcData), ZipArchiveMode.Read);
        
        ZipArchiveEntry swfEntry = archive.GetEntry("library.swf")!;

        byte[] swfData = new byte[swfEntry.Length];
        
        await using Stream stream = swfEntry.Open();
        
        await stream.ReadExactlyAsync(swfData, 0, swfData.Length);

        return swfData;
    }

    class TaskConfigJson
    {
        [JsonProperty("label")]
        public string Label;

        [JsonProperty("dependsOn")]
        public string[] DependsOn;

        [JsonProperty("asconfig")]
        public string ASConfigPath;
    }
}