using Core.GameObjects;

namespace Platform.Models.Core.Parent;

public interface IParent
{
    public GameObject? GetChild(string name);
    public GameObject? GetChild(long id);
    
    public GameObject[] GetChildren();
}