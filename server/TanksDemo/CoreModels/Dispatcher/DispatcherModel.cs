using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using Core.GameObjects;
using Core.Model;
using Core.Model.Registry;
using GameResources;
using Network.Protocol;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace CoreModels.Dispatcher;

[ModelEntity(typeof(DispatcherEntity))]
[Model]
internal class DispatcherModel(long modelId) : ModelBase<IDispatcherModelClient>(1), ObjectAttachListener.Attached, IDispatcher
{
    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    public void ObjectAttached(NetworkSession session)
    {
        Clients(Context.Object, [session], client => client.InitSpace(Context.Object.Space.Id));
    }

    public void LoadEntities(GameObject[] objects, IEnumerable<NetworkSession> sessions)
    {
        foreach (NetworkSession session in sessions)
        {
            LoadEntities(objects, session);
        }
    }

    private void LoadEntities(GameObject[] objects, NetworkSession session)
    {
        long?[] ids = objects.Select(obj => (long?)obj.Id).ToArray();
        
        ModelCommunicationService.SendSpaceCommand(Context.Object.Id, 1, [session],
            (ByteArray buffer, NullMap nullMap) =>
            {

                GeneralDataEncoder.Encode(ids, buffer, nullMap);

                foreach (GameObject gameObject in objects)
                {
                    GeneralDataEncoder.Encode((GameObject?)null, buffer, nullMap); //parentId in old system

                    (long modelId, ModelInitParams? modelParams)[] modelsParams = null;
                    ModelContext.RunLocked(() =>
                    {
                        PutContext(new ModelContext(gameObject, session));
                        modelsParams = gameObject.ModelsIds
                            .Where(modelId => !ModelRegistry.IsServerOnlyModel(modelId))
                            .Select(modelId => (modelId, GetModelInitData(modelId)))
                            .ToArray();
                        PopContext();
                    });

                    long?[]? modelsIds = modelsParams.Select(
                        entry => (long?)entry.modelId).ToArray();

                    GeneralDataEncoder.Encode(typeof(long?[]), modelsIds, buffer, nullMap, true);

                    foreach (var entry in modelsParams)
                    {
                        if(entry.modelParams == null)
                            continue;
                        int fieldsNum = entry.modelParams.FieldsInfo.Length;
                        for (int i = 0; i < fieldsNum; i++)
                        {
                            FieldInfo fieldInfo = entry.modelParams.FieldsInfo[i];
                            GeneralDataEncoder.Encode(fieldInfo.FieldType,
                                entry.modelParams.FieldsData[i],
                                buffer, nullMap,
                                Nullable.GetUnderlyingType(fieldInfo.FieldType) != null
                                || fieldInfo.GetCustomAttribute<MaybeNullAttribute>() != null);
                        }
                    }
                }

            });
    }

    private ModelInitParams? GetModelInitData(long modelId)
    {
        IModel model = ModelRegistry.GetModelById(modelId);

        Type? interfaceType = model.GetClientConstructorInterfaceType();

        if (interfaceType == null)
            return null;

        Type initDataType = interfaceType.GetGenericArguments().First();

        MethodInfo getDataMethod = interfaceType.GetMethod("GetClientInitData")!;

        object dataInstance = getDataMethod.Invoke(model, [])!;

        FieldInfo[] fields = initDataType.GetFields(BindingFlags.Instance | BindingFlags.Public);

        object?[] fieldsValues = fields.Select(field => field.GetValue(dataInstance)).ToArray();

        return new ModelInitParams(fieldsValues, fields);
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