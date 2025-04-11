using Core.GameObjects;

namespace Platform.Models.Core.Child;

public interface IChild
{
    public GameObject GetParent();
    
    public void ChangeParent(GameObject newParent);
}