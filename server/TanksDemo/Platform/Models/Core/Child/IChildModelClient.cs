namespace Platform.Models.Core.Child;

public interface IChildModelClient
{
    public void InitObject(long parentId);

    public void ChangeParent(long parentId);
}