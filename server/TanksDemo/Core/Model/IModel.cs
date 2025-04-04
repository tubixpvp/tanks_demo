namespace Core.Model;

public interface IModel
{
    public long Id { get; }

    public Type GetClientInterfaceType();
}