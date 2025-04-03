using OSGI.Services;

namespace Core.Space;

[Service]
public class SpaceRegistry
{
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

    public Space CreateSpace(long id, string name)
    {
        Space space = new Space(id, name);
        _spacesById.Add(id, space);
        _spacesByName.Add(name, space);
        return space;
    }
}