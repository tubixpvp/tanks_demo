using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Utils;

public static class JSON
{
    public static T? Deserialize<T>(string text)
    {
        return JsonConvert.DeserializeObject<T>(RemoveComments(text));
    }

    public static JObject ParseObject(string text)
    {
        return JObject.Parse(RemoveComments(text));
    }

    public static string Serialize<T>(T obj)
    {
        return JsonConvert.SerializeObject(obj);
    }

    private static string RemoveComments(string text)
    {
        string[] lines = text.Split('\n');
        int linesLength = lines.Length;
        for (int i = 0; i < linesLength; i++)
        {
            if (lines[i].Trim().StartsWith("//"))
            {
                lines[i] = string.Empty;
            }
        }
        return string.Join('\n', lines);
    }
}