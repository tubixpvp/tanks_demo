namespace A3DConverter.Parser3DS;

internal class MaterialData
{
    public string? Name;

    public int Color;

    public int Specular;

    public int Glossiness;

    public int Transparency;
   
    public MapData? DiffuseMap;
   
    public MapData? OpacityMap;
}