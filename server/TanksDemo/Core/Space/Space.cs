using Network.Session;

namespace Core.Space;

public class Space
{
    public long Id { get; }
    public string Name { get; }

    internal Space(long id, string name)
    {
        Id = id;
        Name = name;
    }

    public void AddSession(NetworkSession spaceSession)
    {
    }
    
}