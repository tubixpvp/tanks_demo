namespace ClientGenerator.Flash;

internal static class FlashGenerationUtils
{
    public static string GetDirectoryByNamespace(string nameSpace)
    {
        return string.Join(Path.DirectorySeparatorChar, nameSpace.ToLower().Split('.'));
    }

    public static string MakeGetCodecCodeFragment(Type fieldType, FlashCodeGenerator generator)
    {
        if (fieldType.IsArray)
        {
            Type elementType = fieldType.GetElementType()!;
            Type? elementUnderlyingType = Nullable.GetUnderlyingType(elementType);
            bool optionalElements = elementUnderlyingType != null;
            if (elementUnderlyingType != null)
                elementType = elementUnderlyingType;

            generator.AddImport(elementType);

            return $"codecFactory.getArrayCodec({FlashCodeGenerator.GetFlashImportTypeString(elementType)}, {(!optionalElements).ToString().ToLower()}, 1);";
        }
        generator.AddImport(fieldType);

        return $"codecFactory.getCodec({FlashCodeGenerator.GetFlashImportTypeString(fieldType)});";
    }

    public static string MakeTypeDecodeCodeFragment(Type fieldType, bool optional)
    {
        string flashDeclarationName = FlashCodeGenerator.GetFlashDeclarationTypeString(fieldType);
        return $"codec.decode(dataInput, nullMap, {(!optional).ToString().ToLower()}) as {flashDeclarationName};";
    }

    public static string MakeTypeEncodeCodeFragment(bool optional, string varName)
    {
        return $"codec.encode(dest, {varName}, nullMap, {(!optional).ToString().ToLower()});";
    }
    
    public static string FirstLetterToLower(string str)
    {
        return str[0].ToString().ToLower() + str.Substring(1);
    }
}