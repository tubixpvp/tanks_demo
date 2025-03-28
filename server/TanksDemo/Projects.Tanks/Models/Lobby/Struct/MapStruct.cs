using Core.Generator;

namespace Projects.Tanks.Models.Lobby.Struct;

[ClientExport]
public class MapStruct
{
    public long Id;

    public string Name;
    
    public string Description;

    public int TanksOnline;

    public int MaxTanksOnline;

    public long PreviewResourceId;
}