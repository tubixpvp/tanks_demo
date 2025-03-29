using System.Text;
using System.Xml.Linq;
using Logging;
using Utils;

namespace ResourcesBuilder;

internal class ResourceBuilderRunner
{
    public static void Main(string[] args)
    {
        _ = new ResourceBuilderRunner(ParametersUtil.FromRunArguments(args));
    }

    public static readonly LoggerService LoggerService = new ();
    
    public readonly bool DebugMode;

    private const string ResourcesFolder = "resources";

    private readonly ILogger _logger = LoggerService.GetLogger(typeof(ResourceBuilderRunner));

    private readonly string _resourcesOutputDir;

    private ResourceBuilderRunner(ParametersUtil launchParams)
    {
        _logger.Log(LogLevel.Info, "Starting resource generator");

        DebugMode = launchParams.GetBoolean("debug");

        _resourcesOutputDir = launchParams.GetString("output") ?? throw new Exception("Output directory is not provided");
        _resourcesOutputDir = Path.GetFullPath(_resourcesOutputDir);

        _logger.Log(LogLevel.Info, "Output path: " + _resourcesOutputDir);
        
        if (Directory.Exists(_resourcesOutputDir))
        {
            Directory.Delete(_resourcesOutputDir, true);
        }
        Directory.CreateDirectory(_resourcesOutputDir);
        
        SafeTask.Run(async () =>
        {
            await (new LibrariesBuilder(launchParams, this).Build());
            
        }).Wait();
    }

    public async Task BuildResource(long id, long version, string name, Dictionary<string, byte[]> filesData)
    {
        filesData.Add("info.xml", Encoding.UTF8.GetBytes(MakeInfoForResource(id,name)));
        
        string resourceOutputDir = MakeResourcePath(id, version);

        _logger.Log(LogLevel.Debug, $"Writing resource ({id}, {version}) to {resourceOutputDir}");

        if (!Directory.Exists(resourceOutputDir))
        {
            Directory.CreateDirectory(resourceOutputDir);
        }

        await Task.WhenAll(filesData.Select(entry => 
            WriteResourceFile(resourceOutputDir, entry.Key, entry.Value)));
    }

    private static string MakeInfoForResource(long id, string name)
    {
        return new XElement("info",
            new XAttribute("name", name)
        ).ToString();
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

        int radix = 16;

        builder.Append(ToStringOfBase(idBytes.ReadUInt(),radix) + "/");
        builder.Append(ToStringOfBase(idBytes.ReadUShort(), radix) + "/");
        builder.Append(ToStringOfBase(idBytes.ReadByte(), radix) + "/");
        builder.Append(ToStringOfBase(idBytes.ReadByte(), radix) + "/");
        builder.Append('/');
        
        ByteArray versionBytes = LongToBytes(version);

        uint verHigh = versionBytes.ReadUInt();
        uint verLow = versionBytes.ReadUInt();
        if (verHigh != 0)
        {
            builder.Append(ToStringOfBase(verHigh, radix));
        }
        builder.Append(ToStringOfBase(verLow,radix) + "/");
        
        return Path.GetFullPath(Path.Combine(_resourcesOutputDir, ResourcesFolder, builder.ToString())); //get full path to convert path to system-dependent style
    }

    private static string ToStringOfBase(long val, int toBase)
    {
        return (Math.Sign(val) < 0 ? '-' : string.Empty) + val.ToString("x");
    }

    private static ByteArray LongToBytes(long val)
    {
        ByteArray bytes = new();
        bytes.WriteLong(val);
        bytes.Position = 0;
        return bytes;
    }

    public async Task WriteFile(string relativePath, byte[] fileData)
    {
        string path = Path.Combine(_resourcesOutputDir, relativePath);
        await File.WriteAllBytesAsync(path, fileData);
    }
}