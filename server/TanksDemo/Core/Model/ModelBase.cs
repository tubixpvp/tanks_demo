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


    protected void Clients(GameObject gameObject, IEnumerable<NetworkSession> sessions, Action<CI> callback)
    {
        ModelCommunicationService.GetSender(gameObject, this, sessions, callback);
    }

    protected ILogger GetLogger()
    {
        return LoggerService.GetLogger(GetType());
    }
}