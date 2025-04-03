namespace OSGI.Services;

[AttributeUsage(AttributeTargets.Class)]
public class ServiceAttribute(Type? serviceKey = null) : Attribute
{
    public readonly Type? ServiceKey = serviceKey;
}