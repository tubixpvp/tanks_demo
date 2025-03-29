namespace Utils;

public class ParametersUtil
{
    private readonly Dictionary<string, string> _parameters;
    
    private ParametersUtil(Dictionary<string, string> parameters)
    {
        _parameters = parameters;
    }

    public string? GetString(string key)
    {
        return _parameters.GetValueOrDefault(key);
    }
    public bool GetBoolean(string key)
    {
        return GetString(key) == "true";
    }
    public int? GetInt(string key)
    {
        return _parameters.TryGetValue(key, out var value) ? int.Parse(value) : null;
    }
    
    public static ParametersUtil FromRunArguments(string[] args)
    {
        args = string.Join(' ', args).Split(' ');
        
        Dictionary<string, string> parameters = new();

        for (int i = 0; i < args.Length;)
        {
            if (args[i].StartsWith('-'))
            {
                string key = args[i].Remove(0, 1);
                string value = string.Empty;

                i++;
                while (i < args.Length && !args[i].StartsWith('-'))
                {
                    value += args[i] + " ";
                    i++;
                }
                
                value = value.Trim();
                parameters.Add(key, value);
            }
        }

        return new ParametersUtil(parameters);
    }
}