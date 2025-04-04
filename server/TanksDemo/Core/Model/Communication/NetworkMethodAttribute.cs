namespace Core.Model.Communication;

[AttributeUsage(AttributeTargets.Method)]
public class NetworkMethodAttribute() : Attribute
{
    public long? MethodId { get; set; }
    
    public long CustomMethodId
    {
        get => throw new InvalidOperationException();
        set => MethodId = value; 
    }
}