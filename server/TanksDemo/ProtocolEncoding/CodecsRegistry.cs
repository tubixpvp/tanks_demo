using System.Reflection;
using OSGI.Services;
using Utils;

namespace ProtocolEncoding;

[Service]
public class CodecsRegistry
{

    private readonly Dictionary<Type, ICustomCodec> _customCodecs = new();


    public CodecsRegistry()
    {
        Type[] customCodecsTypes = AttributesUtil.GetTypesWithAttribute(typeof(CustomCodecAttribute));

        foreach (Type customCodecType in customCodecsTypes)
        {
            CustomCodecAttribute attribute = customCodecType.GetCustomAttribute<CustomCodecAttribute>()!;

            ICustomCodec codecInstance = (ICustomCodec)Activator.CreateInstance(customCodecType)!;

            _customCodecs.Add(attribute.DataType, codecInstance);
        }
    }

    public ICustomCodec? GetCodec(Type type)
    {
        return _customCodecs.GetValueOrDefault(type);
    }

}