namespace ProtocolEncoding;

public class CustomCodecAttribute(Type dataType) : Attribute
{
    public readonly Type DataType = dataType;
}