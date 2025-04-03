using System.Reflection;
using Core.Model;

namespace Core.GameObjects.Adapts;

internal class GameObjectAdaptProxy : DispatchProxy
{
    private GameObject _gameObject;

    private object[] _handlers;
    
    private void Init(GameObject gameObject, object[] handlers)
    {
        _gameObject = gameObject;
        _handlers = handlers;
    }
    
    protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
    {
        if (targetMethod == null)
            return null;

        object? returnValue = null;

        lock (ModelContext.Lock)
        {
            ModelContext context = new ModelContext(_gameObject, ModelGlobals.Context?.Session);

            ModelGlobals.PutContext(context);

            foreach (object handler in _handlers)
            {
                targetMethod.Invoke(handler, args);
            }

            ModelGlobals.PopContext();
        }

        return returnValue;
    }

    public static T Create<T>(GameObject gameObject, T[] handlers) where T : class
    {
        T proxyT = DispatchProxy.Create<T, GameObjectAdaptProxy>();
        
        GameObjectAdaptProxy proxy = (proxyT as GameObjectAdaptProxy)!;
        proxy.Init(gameObject, handlers);

        return proxyT;
    }
}