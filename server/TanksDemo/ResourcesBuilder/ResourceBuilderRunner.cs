using System.Text;
using Logging;
using Utils;

namespace ResourcesBuilder;

public class ResourceBuilderRunner
{
    public static void Main(string[] args)
    {
        _ = new ResourceBuilderRunner(ParametersUtil.FromRunArguments(args));
    }

    public static readonly LoggerService LoggerService = new ();

    private readonly ILogger _logger = LoggerService.GetLogger(typeof(ResourceBuilderRunner));

    private readonly string _resourcesOutputDir;

    private ResourceBuilderRunner(ParametersUtil launchParams)
    {
        _logger.Log(LogLevel.Info, "Starting resource generator");

        _resourcesOutputDir = Path.GetFullPath(launchParams.GetString("output") ?? throw new Exception("Output directory is not provided"));

        _logger.Log(LogLevel.Info, "Output path: " + _resourcesOutputDir);
        
        Task.Run(async () =>
        {
            if (Directory.Exists(_resourcesOutputDir))
            {
                Directory.Delete(_resourcesOutputDir, true);
            }
            Directory.CreateDirectory(_resourcesOutputDir);
            
            await (new LibrariesBuilder(launchParams, this).Build());
            
            
        }).Wait();
    }

    public async Task BuildResource(long id, long version, Dictionary<string, byte[]> filesData)
    {
        string resourceOutputDir = MakeResourcePath(id, version);

        _logger.Log(LogLevel.Debug, $"Writing resource ({id}, {version}) to {resourceOutputDir}");

        if (!Directory.Exists(resourceOutputDir))
        {
            Directory.CreateDirectory(resourceOutputDir);
        }

        await Task.WhenAll(filesData.Select(entry => 
            WriteResourceFile(resourceOutputDir, entry.Key, entry.Value)));
    }

    private async Task WriteResourceFile(string outputDir, string fileName, byte[] fileData)
    {
        await File.WriteAllBytesAsync(Path.Combine(outputDir, fileName), fileData);
    }

    private string MakeResourcePath(long id, long version)
    {
        //return Path.Combine(_resourcesOutputDir, $"{id}/{version}/");

        ByteArray idBytes = LongToBytes(id);

        StringBuilder builder = new StringBuilder();

        builder.Append(idBytes.ReadInt().ToString("x") + "/");
        builder.Append(idBytes.ReadShort().ToString("x") + "/");
        builder.Append(idBytes.ReadByte().ToString("x") + "/");
        builder.Append(idBytes.ReadByte().ToString("x") + "/");
        builder.Append('/');
        
        ByteArray versionBytes = LongToBytes(version);

        int verHigh = versionBytes.ReadInt();
        int verLow = versionBytes.ReadInt();
        if (verHigh != 0)
        {
            builder.Append(verHigh.ToString("x"));
        }
        builder.Append(verLow.ToString("x") + "/");
        
        return Path.GetFullPath(Path.Combine(_resourcesOutputDir, builder.ToString())); //get full path to convert path to system-dependent style
    }

    private static ByteArray LongToBytes(long val)
    {
        ByteArray bytes = new();
        bytes.WriteInt(val);
        bytes.Position = 0;
        return bytes;
    }
}