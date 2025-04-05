namespace Core.Model;

[AttributeUsage(AttributeTargets.Class)]
public class ModelAttribute : Attribute
{
    public bool ServerOnly { get; set; }
}