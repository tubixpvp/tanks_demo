namespace Core.Generator;

public class ClientExportAttribute(bool generateCodec, string? customPackage = null) : Attribute
{
    public readonly bool GenerateCodec = generateCodec;
    public readonly string? CustomPackage = customPackage;
}