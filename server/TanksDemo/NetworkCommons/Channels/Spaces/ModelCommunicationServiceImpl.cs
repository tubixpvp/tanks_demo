using System.Reflection;
using Core.GameObjects;
using Core.Model;
using Core.Model.Communication;
using Core.Model.Registry;
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
            proxy.Init(gameObject.Id, sessions);
            
            callback(proxyT);
        }
    }

    public async Task InvokeServerMethod(ModelContext context, long methodId)
    {
        (MethodInfo methodInfo, IModel model, bool isAsync) = ModelRegistry.GetModelAndMethodById(methodId);

        if (isAsync)
        {
            Task? task = (Task?)methodInfo.Invoke(model, [ context ]);

            if (task != null)
                await SafeTask.AddListeners(task, context.Session!.OnError);
            
            return;
        }
        
        ModelContext.RunLocked(() =>
        {
            ModelGlobals.PutContext(context);
            
            methodInfo.Invoke(model, []);
            
            ModelGlobals.PopContext();
        });
    }


    class SendProxy : DispatchProxy
    {
        private long _objectId;
        
        private IEnumerable<NetworkSession> _sessions;

        public void Init(long objectId, IEnumerable<NetworkSession> sessions)
        {
            _objectId = objectId;
            _sessions = sessions;
        }
        
        protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
        {
            if (targetMethod == null)
                return null;

            long methodId = ModelRegistry.GetMethodId(targetMethod);

            SpaceCommand command = new SpaceCommand(_objectId, methodId);

            if (args != null)
            {
                ParameterInfo[] parameters = targetMethod.GetParameters();
                int argsNum = args.Length;

                for (int i = 0; i < argsNum; i++)
                {
                    Type paramType = parameters[i].ParameterType;
                    GeneralDataEncoder.Encode(paramType, args[i], command.DataBuffer, command.NullMap);
                }
            }

            SpaceChannelHandler.SendCommand(command, _sessions);

            return null;
        }
    }
}