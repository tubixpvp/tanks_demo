namespace Core.Model;

[AttributeUsage(AttributeTargets.Class)]
public class ModelEntityAttribute(Type entityType) : Attribute
{
    public readonly Type EntityType = entityType;
}