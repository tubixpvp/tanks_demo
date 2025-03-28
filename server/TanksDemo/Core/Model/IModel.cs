using System.Reflection;

namespace Core.Model;

public interface IModel
{
    public long Id { get; }

    public Type GetClientInterfaceType();
    public Dictionary<byte, MethodInfo> GetServerInterfaceMethods();
}