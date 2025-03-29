using System.IO.Compression;
using Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Utils;

namespace ResourcesBuilder;

internal class LibrariesBuilder
{
    private const string AlternativaLoaderName = "AlternativaLoader";
    private const string BinaryFolder = "bin";
    private const string LibrariesConfig = "libs_hash.json";
    
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
        string libsDataPath = Path.Combine(_clientRootDir, LibrariesConfig);

        LibsConfigJson libsData;
        if (!File.Exists(libsDataPath))
        {
            libsData = new LibsConfigJson()
            {
                Libs = new Dictionary<string, LibConfig>()
            };
        }
        else
        {
            libsData = JsonConvert.DeserializeObject<LibsConfigJson>(
                await File.ReadAllTextAsync(libsDataPath))!;
        }
        
        
        JObject config = JObject.Parse(await File.ReadAllTextAsync(_tasksConfigPath));
        
        _tasks = config["tasks"]!.ToObject<TaskConfigJson[]>()!;

        TaskConfigJson? clientBuildTask = _tasks.FirstOrDefault(task => task.Label == _buildClientTaskName);

        if (clientBuildTask == null)
            throw new Exception("Build client task is not found in config: " + _buildClientTaskName);

        string[] libs = clientBuildTask.DependsOn.Where(name => name.StartsWith("Build "))
            .Select(name => name.Substring("Build ".Length)).ToArray();
        libs = libs.Except([AlternativaLoaderName]).ToArray();
        
        _logger.Log(LogLevel.Info, 
            "Libraries from config: " + string.Join(", ", libs));

        int libIndex = 0;

        //await Task.WhenAll(libs.Select(
        //    libName => BuildLibrary(libName, libIndex++, libsData)));
        foreach (string libName in libs)
        {
            await BuildLibrary(libName, libIndex++, libsData);
        }

        await File.WriteAllTextAsync(libsDataPath, JsonConvert.SerializeObject(libsData, Formatting.Indented));
    }

    private async Task BuildLibrary(string name, int libIndex, LibsConfigJson libsData)
    {
        string libraryDir = Path.GetFullPath(Path.Combine(_libraryBinariesRoot, name));

        _logger.Log(LogLevel.Debug, "Build library " + libraryDir);

        byte[] librarySwcData = await File.ReadAllBytesAsync(Path.Combine(libraryDir, "library.swc"));

        string libHash = HashUtil.GetBase64SHA256String(librarySwcData);
        
        if (!libsData.Libs.TryGetValue(name, out LibConfig? libData))
        {
            libData = new LibConfig()
            {
                ResourceId = _random.NextInt64(10000000000000,99999999999999),
                ResourceVersion = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
                LibraryFileHash = libHash
            };
            _logger.Log(LogLevel.Debug, $"Library config for {name} not exists, created new: {JsonConvert.SerializeObject(libData)}");
            lock (libsData.Libs)
            {
                libsData.Libs.Add(name, libData);
            }
        }
        else if(libData.LibraryFileHash != libHash)
        {
            libData.ResourceVersion = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(); //update the version
        }
        
        //unpack swf from swc
        using ZipArchive archive = new ZipArchive(new MemoryStream(librarySwcData), ZipArchiveMode.Read);
        
        ZipArchiveEntry swfEntry = archive.GetEntry("library.swf")!;

        byte[] swfData = new byte[swfEntry.Length];
        await using (Stream stream = swfEntry.Open())
        {
            await stream.ReadExactlyAsync(swfData, 0, swfData.Length);
        }

        //write to file
        await _resourceBuilder.BuildResource(libData.ResourceId, libData.ResourceVersion,
            new(){["library.swf"] = swfData});
    }

    class TaskConfigJson
    {
        [JsonProperty("label")]
        public string Label;

        [JsonProperty("dependsOn")]
        public string[] DependsOn;
    }

    class LibsConfigJson
    {
        [JsonProperty("libs")]
        public Dictionary<string, LibConfig> Libs;
    }
    class LibConfig
    {
        [JsonProperty("id")]
        public long ResourceId;
        
        [JsonProperty("version")]
        public long ResourceVersion;

        [JsonProperty("hash")] 
        public string LibraryFileHash;
    }
}