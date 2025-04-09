using GameResources;
using Logging;
using Network.Channels;
using Network.Session;
using NetworkCommons.Channels.Control;
using NetworkCommons.Channels.Control.Commands.Client;
using NetworkCommons.Channels.Spaces;
using Newtonsoft.Json;
using OSGI.Services;

namespace CoreModels.Resources;

[Service]
public class ClientResourcesService : IClientResourceLoadListener, IOSGiInitListener
{

    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static ControlChannelHandler ControlChannelHandler;

    [InjectService]
    private static LoggerService LoggerService;

    [InjectService]
    private static ResourceRegistry ResourceRegistry;

    
    private const string SessionDataKey = "ResourcesData";


    private ILogger _logger;


    public ClientResourcesService()
    {
        OSGi.RegisterService(typeof(IClientResourceLoadListener), this);
    }

    public void OnOSGiInited()
    {
        _logger = LoggerService.GetLogger(GetType());
    }

    public void LoadResources(NetworkSession session, ResourceInfo[] resources, Action resourcesLoadedCallback)
    {
        if (session.ChannelType == ProtocolChannelType.Space)
        {
            session = SpaceChannelHandler.GetControlSessionBySpace(session);
        }

        SessionResourcesData sessionData = GetSessionData(session);

        int loadId = sessionData.LoadCounter++;

        sessionData.LoadCallbacks.TryAdd(loadId, resourcesLoadedCallback);

        ResourceInfo[][] batches = BuildBatches(resources);
        
        _logger.Log(LogLevel.Debug, 
            $"Loading resources request: loadId={loadId}, batches={JsonConvert.SerializeObject(batches)}");
        
        ControlChannelHandler.SendLoadResources(session, loadId, batches);
    }

    private ResourceInfo[][] BuildBatches(ResourceInfo[] resources)
    {
        //split by dependencies

        Dictionary<ResourceInfo, List<ResourceInfo>> dependentResourcesTable = new();
        Dictionary<ResourceInfo, int> dependenciesNumTable = new();

        BuildDependencyTree(resources, dependentResourcesTable, dependenciesNumTable);
        
        List<ResourceInfo[]> output = new();
        
        List<ResourceInfo> batch = new();

        Queue<ResourceInfo> resourcesQueue = new Queue<ResourceInfo>(resources);

        while (resourcesQueue.Any())
        {
            batch.Clear();
            
            int queueSize = resourcesQueue.Count;
            for (int i = 0; i < queueSize; i++)
            {
                ResourceInfo resourceInfo = resourcesQueue.Dequeue();

                batch.Add(resourceInfo);

                if (dependentResourcesTable.TryGetValue(resourceInfo, out List<ResourceInfo>? dependentResources))
                {
                    foreach (ResourceInfo dependencyInfo in dependentResources)
                    {
                        int dependenciesNum = dependenciesNumTable[dependencyInfo];
                        dependenciesNum--;
                        dependenciesNumTable[dependencyInfo] = dependenciesNum;
                        if (dependenciesNum == 0)
                        {
                            resourcesQueue.Enqueue(dependencyInfo);
                        }
                    }
                }
            }

            output.Add(batch.ToArray());
        }
        
        return output.ToArray();
    }

    private void BuildDependencyTree(ResourceInfo[] resources, Dictionary<ResourceInfo, List<ResourceInfo>> dependentResourcesTable, Dictionary<ResourceInfo, int> dependenciesNumTable)
    {
        List<ResourceInfo>? externalDependencies = null;
        
        while (true)
        {
            foreach (ResourceInfo resourceInfo in resources)
            {
                dependenciesNumTable[resourceInfo] = resourceInfo.DependenciesIds.Length;

                foreach (string dependencyId in resourceInfo.DependenciesIds)
                {
                    ResourceInfo dependentResourceInfo = ResourceRegistry.GetResourceInfo(dependencyId);

                    if (!resources.Contains(dependentResourceInfo))
                    {
                        //dependency wasn't included in provided resources list
                        externalDependencies ??= new();
                        externalDependencies.Add(dependentResourceInfo);
                    }

                    if (!dependentResourcesTable.TryGetValue(dependentResourceInfo, out List<ResourceInfo>? dependOn))
                    {
                        dependentResourcesTable.Add(dependentResourceInfo, dependOn = new());
                    }

                    dependOn.Add(resourceInfo);
                }
            }

            if (externalDependencies != null)
            {
                resources = externalDependencies.ToArray();
                externalDependencies.Clear();
                continue;
            }

            break;
        }
    }

    public void OnResourceLoaded(NetworkSession controlSession, int batchId)
    {
        SessionResourcesData sessionData = GetSessionData(controlSession);

        if (sessionData.LoadCallbacks.TryGetValue(batchId, out Action? loadCallback))
        {
            loadCallback();
            return;
        }

        _logger.Log(LogLevel.Warn, "Resource load callback not found: " + batchId);
    }

    private SessionResourcesData GetSessionData(NetworkSession session)
    {
        SessionResourcesData? data = session.GetAttribute<SessionResourcesData>(SessionDataKey);
        if (data == null)
        {
            data = new SessionResourcesData();
            session.SetAttribute(SessionDataKey, data);
        }
        return data;
    }
}