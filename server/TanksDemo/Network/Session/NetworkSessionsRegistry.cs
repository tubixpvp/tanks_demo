using OSGI.Services;

namespace Network.Session;

[Service]
public class NetworkSessionsRegistry
{
    
    private readonly List<NetworkSession> _sessions = new();


    public void AddSession(NetworkSession session)
    {
        lock (_sessions)
        {
            _sessions.Add(session);
        }
    }

    public void RemoveSession(NetworkSession session)
    {
        lock (_sessions)
        {
            _sessions.Remove(session);
        }
    }
    
}