using System.Reflection;
using Core.Model.Communication;
using Core.Model.Registry;
using OSGI.Services;

namespace Core.Model;

public static class ModelUtils
{
    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    
    public const string InitObjectFunc = "InitObject";

    
    public static MethodInfo[] GetServerInterfaceMethods(Type modelType)
    {
        MethodInfo[] allMethods = modelType.GetMethods(BindingFlags.NonPublic | BindingFlags.Instance);

        return allMethods.Where(methodInfo => methodInfo.GetCustomAttribute<NetworkMethodAttribute>() != null).ToArray();
    }
}