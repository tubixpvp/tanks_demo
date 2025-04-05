using Core.GameObjects;
using Core.Model;
using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace CoreModels.Dispatcher;

[ModelEntity(typeof(DispatcherEntity))]
[Model]
internal class DispatcherModel(long modelId) : ModelBase<IDispatcherModelClient>(1), ObjectClientListener.Attached, IDispatcher
{
    
    public void ObjectAttached(NetworkSession session)
    {
        Clients(Context.Object, [session], client => client.InitSpace(Context.Object.Space.Id));
    }

    public void LoadEntities(GameObject[] objects, IEnumerable<NetworkSession> sessions)
    {
        long?[] ids = objects.Select(obj => (long?)obj.Id).ToArray();
        
        ModelCommunicationService.SendSpaceCommand(Context.Object.Id, 1, sessions,
            (ByteArray buffer, NullMap nullMap) =>
            {

                GeneralDataEncoder.Encode(ids, buffer, nullMap);

                foreach (GameObject gameObject in objects)
                {
                    GeneralDataEncoder.Encode(gameObject.Parent, buffer, nullMap);

                    (long modelId, ModelInitParams? modelParams)[] modelsParams =
                        gameObject.ModelsIds
                            .Where(modelId => !ModelRegistry.IsServerOnlyModel(modelId))
                            .Select(modelId => (modelId, gameObject.GetClientInitParams(modelId)))
                            .ToArray();

                    long?[]? modelsIds = modelsParams.Select(
                        entry => (long?)entry.modelId).ToArray();
                    
                    GeneralDataEncoder.Encode(modelsIds, buffer, nullMap);

                    foreach (var entry in modelsParams)
                    {
                        if(entry.modelParams == null)
                            continue;
                        GeneralDataEncoder.Encode(entry.modelParams, buffer, nullMap);
                    }
                }

            });
    }
    
}