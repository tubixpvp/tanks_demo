using Core.GameObjects;
using Network.Protocol;
using Network.Session;
using Utils;

namespace Core.Model.Communication;

public interface IModelCommunicationService
{
    public void GetSender<CI>(
        GameObject gameObject,
        IModel model,
        IEnumerable<NetworkSession> sessions,
        Action<CI> callback);
    public Task InvokeServerMethod(ModelContext context, long methodId);

    public void SendSpaceCommand(long objectId, long methodId,
        IEnumerable<NetworkSession> sessions,
        Action<ByteArray, NullMap> encodeCallback);
}