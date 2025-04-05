using System.Reflection;
using Network.Channels;
using Network.Protocol;
using Newtonsoft.Json;
using OSGI.Services;
using Utils;

namespace ProtocolEncoding;

public static class GeneralDataEncoder
{

    [InjectService]
    private static CodecsRegistry CodecsRegistry;


    public static void Encode(object? value, NetPacket packet) => Encode(value, packet.PacketBuffer, packet.NullMap);
    public static void Encode(object? value, ByteArray output, NullMap nullMap)
    {
        Type? type = value?.GetType();
        Encode(type, value, output, nullMap);
    }

    public static void Encode(Type? type, object? value, ByteArray output, NullMap nullMap)
    {
        EncodeOptional(type, value, nullMap, out type);

        if (value == null)
            return;
        
        ICustomCodec? customCodec = CodecsRegistry.GetCodec(type);

        if (customCodec != null)
        {
            customCodec.Encode(value, output, nullMap);
            return;
        }

        if (type.IsArray)
        {
            EncodeArray(type, value, output, nullMap);
            return;
        }

        if (type.IsEnum)
        {
            EncodeEnum(type, value, output, nullMap);
            return;
        }
        
        if (type.IsPrimitive)
        {
            throw new Exception("Primitive values must be handled in custom codecs! Type: " + type.FullName);
        }

        EncodeClass(type, value, output, nullMap);
    }

    private static void EncodeClass(Type type, object value, ByteArray output, NullMap nullMap)
    {
        FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance);

        foreach (FieldInfo fieldInfo in fields)
        {
            if (fieldInfo.GetCustomAttribute<ProtocolIgnoreAttribute>() != null)
                continue;

            object? fieldValue = fieldInfo.GetValue(value);

            Encode(fieldInfo.FieldType, fieldValue, output, nullMap);
        }
    }

    private static void EncodeEnum(Type type, object value, ByteArray output, NullMap nullMap)
    {
        Type baseType = type.BaseType!;
        
        object index = Convert.ChangeType(value, baseType);

        CodecsRegistry.GetCodec(baseType)!.Encode(index, output, nullMap);
    }

    private static void EncodeArray(Type type, object value, ByteArray output, NullMap nullMap)
    {
        Array array = (Array)value;
        
        Type elementType = type.GetElementType()!;

        Type? underlyingType = Nullable.GetUnderlyingType(elementType);
        
        bool optionalItems = underlyingType != null;
        
        if (underlyingType != null)
            elementType = underlyingType;

        int length = array.Length;
        
        LengthCodecHelper.EncodeLength(output, length);
        
        ICustomCodec? customCodec = CodecsRegistry.GetCodec(elementType);

        for (int i = 0; i < length; i++)
        {
            object? elementValue = array.GetValue(i);

            if (optionalItems)
            {
                nullMap.AddBit(elementValue == null);
            }
            
            if(elementValue == null)
                continue;

            if (customCodec != null)
                customCodec.Encode(elementValue, output, nullMap);
            else
                Encode(elementType, elementValue, output, nullMap);
        }
    }

    private static void EncodeOptional(Type? type, object? value, NullMap nullMap, out Type? baseType)
    {
        baseType = type;

        if (type == null)
        {
            nullMap.AddBit(true);
            return;
        }
        
        Type? underlyingType = Nullable.GetUnderlyingType(type);
        
        if (underlyingType != null)
        {
            baseType = underlyingType;
            
            nullMap.AddBit(value == null);
        }
        else if (value == null)
        {
            throw new Exception("Cannot encode NULL as NOT-NULL value!");
        }
    }
    
}