using Newtonsoft.Json;

namespace ResourcesBuilder;

public class SWFLibraryData
{
    [JsonProperty("id")]
    public long ResourceId;
        
    [JsonProperty("version")]
    public long ResourceVersion;

    [JsonProperty("hash")] 
    public string LibraryFileHash;
}