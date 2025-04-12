using Core.GameObjects;

namespace Core.Spaces;

public interface IGameObjectTemplates
{
    public GameObject BuildObject(string name, GameObjectsStorage objectsStorage);
}