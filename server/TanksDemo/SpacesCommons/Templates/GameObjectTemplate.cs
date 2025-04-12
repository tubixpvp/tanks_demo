using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace SpacesCommons.Templates;

public class GameObjectTemplate
{
    [JsonProperty("name")]
    public string Name;

    [JsonProperty("entities")]
    public Dictionary<string, JObject> Entities;

    [JsonProperty("children")]
    public GameObjectTemplate[] Children;

    [JsonProperty("attach")]
    public bool AutoAttach;
}