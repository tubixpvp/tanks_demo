using System.Reflection;

namespace Core.Model;

public class ModelInitParams(object?[] args, ParameterInfo[] parameters)
{
    public object?[] ArgumentsData { get; } = args;

    public ParameterInfo[] ParametersInfo { get; } = parameters;
}