using System.Reflection;

namespace CoreModels.Dispatcher;

internal class ModelInitParams(object?[] args, FieldInfo[] fields)
{
    public object?[] FieldsData { get; } = args;

    public FieldInfo[] FieldsInfo { get; } = fields;
}