using System.Reflection;
using Core.GameObjects;
using Core.Model.Communication;
using Core.Model.Registry;
using Network.Session;
using OSGI.Services;

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
            callback(proxyT);
        }
    }


    class SendProxy : DispatchProxy
    {
        private IEnumerable<NetworkSession> _sessions;

        public void Init(IEnumerable<NetworkSession> sessions)
        {
            _sessions = sessions;
        }
        
        protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
        {
            if (targetMethod == null)
                return null;

            long methodId = ModelRegistry.GetMethodId(targetMethod);
            
            Console.WriteLine($"Method id:{methodId} called");

            return null;//
        }
    }
}