using Core.Spaces;
using Network.Session;
using NetworkCommons.Channels.Control;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;

namespace SpacesCommons.ClientControl;

[Service]
public class ClientSpacesControlService : IOSGiInitListener
{
    [InjectService]
    private static ControlChannelHandler ControlChannelHandler;

    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;

    [InjectService]
    private static SpaceRegistry SpaceRegistry;

    public void OnOSGiInited()
    {
        ControlChannelHandler.OnControlSessionInited += OnControlSessionOpened;
    }

    private void OnControlSessionOpened(NetworkSession controlSession)
    {
        ConnectTo(controlSession, "Entrance");
    }

    public void SwitchSpace(NetworkSession spaceSession, string newSpaceName)
    {
        NetworkSession controlSession = SpaceChannelHandler.GetControlSessionBySpace(spaceSession);

        SpaceChannelHandler.DisconnectFromSpace(controlSession, spaceSession);

        ConnectTo(controlSession, newSpaceName);
    }
    private void ConnectTo(NetworkSession controlSession, string spaceName)
    {
        Space space = SpaceRegistry.GetSpaceByName(spaceName);

        SpaceChannelHandler.ConnectToSpace(controlSession, space);
    }
}