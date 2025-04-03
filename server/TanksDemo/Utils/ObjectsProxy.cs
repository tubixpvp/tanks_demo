using System.Reflection;

namespace Utils;

public class ObjectsProxy : DispatchProxy
{
    private IEnumerable<object> _handlers;
    
    private void Init(IEnumerable<object> handlers)
    {
        _handlers = handlers;
    }
    
    protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
    {
        if (targetMethod == null)
            return null;
        
        foreach (object handler in _handlers)
        {
            targetMethod.Invoke(handler, args);
        }

        return null;
    }

    public static T Create<T>(IEnumerable<object> handlers)
    {
        T proxyT = DispatchProxy.Create<T, ObjectsProxy>();
        
        ObjectsProxy proxy = (proxyT as ObjectsProxy)!;
        proxy.Init(handlers);

        return proxyT;
    }
}