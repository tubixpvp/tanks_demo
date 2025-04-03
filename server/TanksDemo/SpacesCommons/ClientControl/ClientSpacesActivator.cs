using Core.Spaces;
using Network.Session;
using NetworkCommons.Channels.Control;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;

namespace SpacesCommons.ClientControl;

[Service]
public class ClientSpacesActivator : IOSGiInitListener
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
        Space space = SpaceRegistry.GetSpaceByName("Entrance");

        SpaceChannelHandler.ConnectToSpace(controlSession, space);
    }
}