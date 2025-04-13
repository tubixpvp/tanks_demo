namespace Core.Model;

public interface IClientConstructor<T> where T : class
{
    public T GetClientInitData();
}