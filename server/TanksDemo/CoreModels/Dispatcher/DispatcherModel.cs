using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using Core.GameObjects;
using Core.Model;
using GameResources;
using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace CoreModels.Dispatcher;

[ModelEntity(typeof(DispatcherEntity))]
[Model]
internal class DispatcherModel(long modelId) : ModelBase<IDispatcherModelClient>(1), ObjectAttachListener.Attached, IDispatcher
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
                    GeneralDataEncoder.Encode((GameObject?)null, buffer, nullMap); //parentId in old system

                    (long modelId, ModelInitParams? modelParams)[] modelsParams =
                        gameObject.ModelsIds
                            .Where(modelId => !ModelRegistry.IsServerOnlyModel(modelId))
                            .Select(modelId => (modelId, gameObject.GetClientInitParams(modelId)))
                            .ToArray();

                    long?[]? modelsIds = modelsParams.Select(
                        entry => (long?)entry.modelId).ToArray();

                    GeneralDataEncoder.Encode(typeof(long?[]), modelsIds, buffer, nullMap, true);

                    foreach (var entry in modelsParams)
                    {
                        if(entry.modelParams == null)
                            continue;
                        int paramsNum = entry.modelParams.ParametersInfo.Length;
                        for (int i = 0; i < paramsNum; i++)
                        {
                            ParameterInfo paramInfo = entry.modelParams.ParametersInfo[i];
                            GeneralDataEncoder.Encode(paramInfo.ParameterType,
                                entry.modelParams.ArgumentsData[i],
                                buffer, nullMap,
                                Nullable.GetUnderlyingType(paramInfo.ParameterType) != null
                                || paramInfo.GetCustomAttribute<MaybeNullAttribute>() != null);
                        }
                    }
                }

            });
    }

    public void UnloadEntities(GameObject[] objects, IEnumerable<NetworkSession> sessions)
    {
        long[] ids = objects.Select(obj => obj.Id).ToArray();
        
        ModelCommunicationService.SendSpaceCommand(Context.Object.Id, 2, sessions,
            (ByteArray buffer, NullMap nullMap) =>
            {
                GeneralDataEncoder.Encode(ids, buffer, nullMap);

                GeneralDataEncoder.Encode(Array.Empty<ResourceInfo>(), buffer, nullMap);
            });
    }
}