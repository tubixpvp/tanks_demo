using System.Reflection;

namespace Core.Model;

public interface IModel
{
    public long Id { get; }

    public Type GetClientInterfaceType();
    public Type? GetClientConstructorInterfaceType();
}