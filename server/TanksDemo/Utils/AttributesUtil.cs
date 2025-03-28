using System.Reflection;
using Newtonsoft.Json.Linq;

namespace Utils;

public static class AttributesUtil
{
    private static Type[]? _allTypes;
    
    public static Type[] GetTypesWithAttribute(Type attributeType)
    {
        return GetAllTypes().Where(type => type.GetCustomAttribute(attributeType, false) != null).ToArray();
    }

    public static Type[] GetAllTypes()
    {
        if (_allTypes != null)
            return _allTypes;

        List<Assembly> assemblies = AppDomain.CurrentDomain.GetAssemblies().ToList();

        string[] loadedAssemblies = assemblies.Select(assembly => assembly.GetName().Name).ToArray()!;
        
        //Console.WriteLine("loaded libs:" + string.Join(',', loadedAssemblies));
        
        //get list of required dlls
        
        List<string> requiredAssemblies = new();

        string appBinaryDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;

        string depsFileName = Directory
            .GetFiles(appBinaryDir, "*.deps.json", SearchOption.TopDirectoryOnly).First();

        JObject depsConfig = JObject.Parse(File.ReadAllText(depsFileName));
        
        string runtimeTarget = depsConfig["runtimeTarget"]!["name"]!.ToObject<string>()!;
        var modules = depsConfig["targets"]![runtimeTarget]!.ToObject<Dictionary<string, JObject>>()!;

        foreach (JObject moduleConfig in modules.Values)
        {
            var dllsConfigs = moduleConfig["runtime"]!.ToObject<Dictionary<string, JObject>>()!;

            foreach (string dllFilePath in dllsConfigs.Keys)
            {
                string assemblyName = Path.GetFileNameWithoutExtension(dllFilePath);
                
                if (!requiredAssemblies.Contains(assemblyName))
                {
                    requiredAssemblies.Add(assemblyName);
                }
            }
        }

        //load all dlls that arent loaded yet
        
        string[] notLoadedAssemblies = requiredAssemblies.Except(loadedAssemblies).ToArray();

        Console.WriteLine("Assemblies to load: " + string.Join(',', notLoadedAssemblies));

        foreach (string assemblyName in notLoadedAssemblies)
        {
            //assemblies.Add(Assembly.LoadFile(Path.Combine(Directory.GetCurrentDirectory(), assemblyName)));
            assemblies.Add(Assembly.Load(assemblyName));
        }
        
        //get all types
        
        _allTypes = assemblies.SelectMany(assembly => assembly.GetTypes()).ToArray();

        return _allTypes;
    }
}