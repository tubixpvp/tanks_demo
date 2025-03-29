using Newtonsoft.Json;
using OSGI.Services;

namespace ResourcesBuilder;

[Service]
public class SWFLibrariesDataService
{
    private const string LibrariesConfig = "libs_data.json";

    public async Task<Dictionary<string, SWFLibraryData>> GetLibsData(string clientRootDir)
    {
        string libsDataPath = Path.Combine(clientRootDir, LibrariesConfig);

        Dictionary<string, SWFLibraryData> libsData;
        if (!File.Exists(libsDataPath))
        {
            libsData = new Dictionary<string, SWFLibraryData>();
        }
        else
        {
            libsData = JsonConvert.DeserializeObject<LibsConfigJson>(
                await File.ReadAllTextAsync(libsDataPath))!.Libs;
        }

        return libsData;
    }

    public async Task WriteLibsData(string clientRootDir, Dictionary<string, SWFLibraryData> libsData)
    {
        string libsDataPath = Path.Combine(clientRootDir, LibrariesConfig);
        
        await File.WriteAllTextAsync(libsDataPath, JsonConvert.SerializeObject(
            new LibsConfigJson()
            {
                Libs = libsData
            }, Formatting.Indented));
    }
    
    
    class LibsConfigJson
    {
        [JsonProperty("libs")]
        public Dictionary<string, SWFLibraryData> Libs;
    }
}