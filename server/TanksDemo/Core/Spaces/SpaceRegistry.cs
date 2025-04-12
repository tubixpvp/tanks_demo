using OSGI.Services;

namespace Core.Spaces;

[Service]
public class SpaceRegistry
{
    private static readonly Random Random = new();
    
    private readonly Dictionary<long, Space> _spacesById = new();
    private readonly Dictionary<string, Space> _spacesByName = new();


    public Space GetSpaceById(long id)
    {
        return _spacesById[id];
    }

    public Space GetSpaceByName(string name)
    {
        return _spacesByName[name];
    }

    public Space CreateSpace(string name, IGameObjectTemplates templatesStorageImpl)
    {
        long id = Random.NextInt64(long.MinValue, long.MaxValue);
        Space space = new Space(id, name, templatesStorageImpl);
        _spacesById.Add(id, space);
        _spacesByName.Add(name, space);
        return space;
    }
}