using Newtonsoft.Json;
using OSGI.Services;

namespace ResourcesBuilder;

[Service]
public class SWFLibrariesDataService
{
    private const string LibrariesConfig = "libs_data.json";

    public async Task<List<SWFLibraryData>> GetLibsData(string clientRootDir)
    {
        string libsDataPath = Path.Combine(clientRootDir, LibrariesConfig);

        List<SWFLibraryData> libsData;
        if (!File.Exists(libsDataPath))
        {
            libsData = new();
        }
        else
        {
            libsData = JsonConvert.DeserializeObject<LibsConfigJson>(
                await File.ReadAllTextAsync(libsDataPath))!.Libs?.ToList() ?? new();
        }

        return libsData;
    }

    public async Task WriteLibsData(string clientRootDir, List<SWFLibraryData> libsData)
    {
        string libsDataPath = Path.Combine(clientRootDir, LibrariesConfig);
        
        await File.WriteAllTextAsync(libsDataPath, JsonConvert.SerializeObject(
            new LibsConfigJson()
            {
                Libs = libsData.ToArray()
            }, Formatting.Indented));
    }
    
    
    class LibsConfigJson
    {
        [JsonProperty("libs_list")]
        public SWFLibraryData[] Libs;
    }
}