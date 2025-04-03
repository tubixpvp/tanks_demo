using System.Collections.Concurrent;
using Core.Spaces;
using Network.Session;

namespace NetworkCommons.Channels.Spaces;

internal class SessionSpacesData
{
    
    public Space? ConnectingSpace { get; set; }
    public Queue<Space> SpacesToConnect { get; } = new();
    
    
    public ConcurrentDictionary<NetworkSession, Space> ConnectedSpaces { get; } = new();

}