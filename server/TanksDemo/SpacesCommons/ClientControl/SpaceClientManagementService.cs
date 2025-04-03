using Core.Space;
using Network.Session;
using NetworkCommons.Channels.Control;
using OSGI.Services;

namespace SpacesCommons.ClientControl;

[Service]
public class SpaceClientManagementService : IOSGiInitListener
{
    [InjectService]
    private static ControlChannelHandler ControlChannelHandler;

    [InjectService]
    private static SpaceRegistry SpaceRegistry;


    private const string SpacesDataKey = "SpacesData";


    private readonly Dictionary<string, List<NetworkSession>> _spaceSessionsById = new();
    

    public void OnOSGiInited()
    {
        ControlChannelHandler.OnControlSessionInited += OnControlSessionOpened;
        ControlChannelHandler.OnSpaceSessionInited += OnSpaceSessionOpened;
    }

    private void OnControlSessionOpened(NetworkSession controlSession)
    {
        Space space = SpaceRegistry.GetSpaceByName("Entrance");

        ConnectToSpace(controlSession, space);
    }
    private void OnSpaceSessionOpened(NetworkSession spaceSession)
    {
        NetworkSession controlSession = ControlChannelHandler.GetControlSessionBySpace(spaceSession);
        
        SessionSpacesData spacesData = GetData(controlSession);

        if (spacesData.ConnectingSpace == null)
        {
            throw new Exception("Not waiting for any space connections");
        }
        
        string sessionId = ControlChannelHandler.GetSessionId(spaceSession)!;

        List<NetworkSession>? spaceSessions;
        lock (_spaceSessionsById)
        {
            if (!_spaceSessionsById.TryGetValue(sessionId, out spaceSessions))
            {
                _spaceSessionsById.Add(sessionId, spaceSessions = new List<NetworkSession>());
            }
        }

        lock (spaceSessions)
        {
            spaceSessions.Add(spaceSession);
        }

        spacesData.ConnectingSpace.AddSession(spaceSession);
    }
    
    public void ConnectToSpace(NetworkSession controlSession, Space space)
    {
        SessionSpacesData spacesData = GetData(controlSession);

        if (spacesData.ConnectingSpace != null)
        {
            //TODO make a queue
            throw new Exception("Already waiting the client for connection to another space!");
        }
        
        spacesData.ConnectingSpace = space;
        
        ControlChannelHandler.SendOpenSpace(controlSession);
    }

    private static SessionSpacesData GetData(NetworkSession controlSession)
    {
        SessionSpacesData? data = controlSession.GetAttribute<SessionSpacesData>(SpacesDataKey);

        if (data == null)
        {
            data = new SessionSpacesData();
            controlSession.SetAttribute(SpacesDataKey, data);
        }

        return data;
    }
}