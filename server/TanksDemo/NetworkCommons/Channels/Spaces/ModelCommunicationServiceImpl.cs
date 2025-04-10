using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using Core.Model.Registry;
using Network.Channels;
using Network.Protocol;
using Network.Session;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Spaces;

[Service(typeof(IModelCommunicationService))]
public class ModelCommunicationServiceImpl : IModelCommunicationService
{
    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static ModelRegistry ModelRegistry;
    
    public void GetSender<CI>(
        GameObject gameObject, 
        IModel model,
        IEnumerable<NetworkSession> sessions, 
        Action<CI> callback)
    {
        CI? proxyT = gameObject.GetData<CI>(typeof(ModelCommunicationServiceImpl));

        if (proxyT == null)
        {
            proxyT = DispatchProxy.Create<CI, SendProxy>()!;

            gameObject.PutData(typeof(ModelCommunicationServiceImpl), proxyT);
        }
        
        SendProxy proxy = (proxyT as SendProxy)!;

        lock (proxy)
        {
            proxy.Init(gameObject, model, sessions);
            
            callback(proxyT);
        }
    }

    public async Task InvokeServerMethod(ModelContext context, long methodId, NetPacket packet)
    {
        (MethodInfo methodInfo, IModel model, bool isAsync) = ModelRegistry.GetModelAndMethodById(methodId);

        ParameterInfo[] parameters = methodInfo.GetParameters();
        int length = parameters.Length;
        object?[] args = new object[length];

        for (int i = 0; i < length; i++)
        {
            args[i] = GeneralDataDecoder.Decode(parameters[i].ParameterType, packet.PacketBuffer, packet.NullMap);
        }
        
        if (isAsync)
        {
            Task? task = (Task?)methodInfo.Invoke(model, new object?[]{context}.Append(args).ToArray());

            if (task != null)
                await SafeTask.AddListeners(task, context.Session!.OnError);
            
            return;
        }
        
        ModelContext.RunLocked(() =>
        {
            ModelGlobals.PutContext(context);

            methodInfo.Invoke(model, args);
            
            ModelGlobals.PopContext();
        });
    }

    public void SendSpaceCommand(
        long objectId, 
        long methodId, 
        IEnumerable<NetworkSession> sessions, 
        Action<ByteArray, NullMap> encodeCallback)
    {
        SpaceCommand command = new SpaceCommand(objectId, methodId);

        encodeCallback(command.DataBuffer, command.NullMap);
        
        SpaceChannelHandler.SendCommand(command, sessions);
    }


    class SendProxy : DispatchProxy
    {
        private GameObject _object;

        private IModel _model;
        
        private IEnumerable<NetworkSession> _sessions;

        public void Init(GameObject gameObject, IModel model, IEnumerable<NetworkSession> sessions)
        {
            _object = gameObject;
            _model = model;
            _sessions = sessions;
        }
        
        protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
        {
            if (targetMethod == null)
                return null;

            if (targetMethod.Name == ModelUtils.InitObjectFunc)
            {
                _object.PutClientInitParams(_model.Id, new ModelInitParams(args!, targetMethod.GetParameters()));
                
                return null;
            }

            long methodId = ModelRegistry.GetMethodId(targetMethod);

            SpaceCommand command = new SpaceCommand(_object.Id, methodId);

            if (args != null)
            {
                ParameterInfo[] parameters = targetMethod.GetParameters();
                int argsNum = args.Length;

                for (int i = 0; i < argsNum; i++)
                {
                    ParameterInfo paramInfo = parameters[i];
                    Type paramType = paramInfo.ParameterType;
                    GeneralDataEncoder.Encode(paramType, args[i], command.DataBuffer, command.NullMap,
                        Nullable.GetUnderlyingType(paramType) != null
                        || paramInfo.GetCustomAttribute<MaybeNullAttribute>() != null);
                }
            }

            SpaceChannelHandler.SendCommand(command, _sessions);

            return null;
        }
    }
}