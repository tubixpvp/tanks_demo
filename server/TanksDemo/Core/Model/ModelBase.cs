using System.Reflection;
using Core.Model.Communication;

namespace Core.Model;

/**
 * Base class for any behaviour model on the server
 */
public abstract class ModelBase<CI> : ModelGlobals, IModel where CI : class
{
    public long Id { get; }
    public Type GetClientInterfaceType() => typeof(CI);
    public Dictionary<byte, MethodInfo> GetServerInterfaceMethods() => _serverMethods;

    /**
     * Methods that can be called from client
     */
    private readonly Dictionary<byte, MethodInfo> _serverMethods = new();
    
    
    protected ModelBase(long id)
    {
        Id = id;
        
        CollectServerMethods();
    }

    private void CollectServerMethods()
    {
        MethodInfo[] methods = GetType().GetMethods(BindingFlags.NonPublic | BindingFlags.Instance);

        byte methodCounter = 0;

        foreach (MethodInfo methodInfo in methods)
        {
            NetworkMethodAttribute? netMethodAttribute = methodInfo.GetCustomAttribute<NetworkMethodAttribute>();

            if (netMethodAttribute != null)
            {
                _serverMethods.Add(methodCounter++, methodInfo);
            }
        }
    }
    

    protected CI Clients(TargetClients target)
    {
        return null;
    }
}