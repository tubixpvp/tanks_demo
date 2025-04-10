using System.Reflection;
using Network.Channels;
using Network.Protocol;
using OSGI.Services;
using Utils;

namespace ProtocolEncoding;

public static class GeneralDataDecoder
{

    [InjectService]
    public static CodecsRegistry CodecsRegistry;


    public static T? Decode<T>(NetPacket packet) => Decode<T>(packet.PacketBuffer, packet.NullMap);
    public static T? Decode<T>(ByteArray bytes, NullMap nullMap)
    {
        Type type = typeof(T);

        bool optional = Nullable.GetUnderlyingType(type) != null;

        return (T?)Decode(type, bytes, nullMap, optional);
    }

    public static object? Decode(Type type, ByteArray bytes, NullMap nullMap)
    {
        Type? underlyingType = Nullable.GetUnderlyingType(type);
        bool optional = underlyingType != null;
        type = underlyingType ?? type;
        return Decode(type, bytes, nullMap, optional);
    }

    public static object? Decode(Type type, ByteArray bytes, NullMap nullMap, bool optional)
    {
        if (IsNull(nullMap, optional))
        {
            return null;
        }
        
        type = Nullable.GetUnderlyingType(type) ?? type;

        ICustomCodec? customCodec = CodecsRegistry.GetCodec(type);

        if (customCodec != null)
        {
            return customCodec.Decode(bytes, nullMap);
        }

        if (type.IsArray)
        {
            return DecodeArray(type, bytes, nullMap, false);
        }

        if (type.IsEnum)
        {
            return DecodeEnum(type, bytes, nullMap);
        }

        if (type.IsPrimitive)
        {
            throw new Exception("Primitive values must be handled in custom codecs! Type: " + type.FullName);
        }

        return DecodeClass(type, bytes, nullMap);
    }

    private static object DecodeClass(Type type, ByteArray bytes, NullMap nullMap)
    {
        object instance = Activator.CreateInstance(type)!;

        FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance);

        foreach (FieldInfo fieldInfo in fields)
        {
            if (fieldInfo.GetCustomAttribute<ProtocolIgnoreAttribute>() != null)
                continue;
            
            Type fieldType = fieldInfo.FieldType;

            Type? underlyingType = Nullable.GetUnderlyingType(fieldType);
            if(underlyingType != null)
                fieldType = underlyingType;

            bool optionalField = underlyingType != null;

            object? value = Decode(fieldType, bytes, nullMap, optionalField);

            fieldInfo.SetValue(instance, value);
        }

        return instance;
    }

    private static Enum DecodeEnum(Type type, ByteArray bytes, NullMap nullMap)
    {
        Type baseType = type.BaseType!;

        //decode index
        object value = CodecsRegistry.GetCodec(baseType)!.Decode(bytes, nullMap);

        //convert to enum item
        return (Enum)Convert.ChangeType(value, type);
    }

    private static Array DecodeArray(Type type, ByteArray bytes, NullMap nullMap, bool optionalElements)
    {
        Type elementType = type.GetElementType()!;
        
        int length = LengthCodecHelper.DecodeLength(bytes);

        Array array = Array.CreateInstance(elementType, length);

        ICustomCodec? customCodec = CodecsRegistry.GetCodec(elementType);
        
        for (int i = 0; i < length; i++)
        {
            if (IsNull(nullMap, optionalElements))
                continue;
            
            if (customCodec != null)
            {
                array.SetValue(customCodec.Decode(bytes, nullMap), i);
            }
            else
            {
                array.SetValue(Decode(elementType, bytes, nullMap, optionalElements), i);
            }
        }

        return array;
    }

    private static bool IsNull(NullMap nullMap, bool optional)
    {
        return optional && nullMap.GetBit();
    }


}