using Core.GameObjects;
using Logging;
using Network.Session;

namespace Core.Model;

/**
 * Base class for any behaviour model on the server
 */
public abstract class ModelBase<CI> : ModelGlobals, IModel where CI : class
{
    public long Id { get; }
    
    protected ModelBase(long id)
    {
        Id = id;
    }
    
    public Type GetClientInterfaceType() => typeof(CI);

    public Type? GetClientConstructorInterfaceType()
    {
        return GetType().GetInterfaces().FirstOrDefault(
            i => i.IsGenericType && i.GetGenericTypeDefinition() == typeof(IClientConstructor<>));
    }


    protected void Clients(GameObject gameObject, IEnumerable<NetworkSession> sessions, Action<CI> callback)
    {
        ModelCommunicationService.GetSender(gameObject, this, sessions, callback);
    }
    protected void Clients(ModelContext context, Action<CI> callback)
    {
        Clients(context.Object, [context.Session!], callback);
    }

    protected ILogger GetLogger()
    {
        return LoggerService.GetLogger(GetType());
    }

    protected T GetEntity<T>()
    {
        return Context.Object.GetModelEntity<T>();
    }

    protected static void PutData(Type type, object data)
    {
        Context.Object.PutData(type, data);
    }
    protected static T? GetData<T>(Type type)
    {
        return Context.Object.GetData<T>(type);
    }
}