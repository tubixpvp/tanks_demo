using Core.Generator;
using Platform.Models.General.World3d.A3D.Engine3d.Core;
using Platform.Models.General.World3d.A3D.Engine3d.Materials;

namespace Platform.Models.General.World3d.A3D;

[ClientExport]
public class A3D
{
    public int Version = 1;
    
    public A3DObject3D RootObject;
    
    public A3DFillMaterial[] FillMaterials;
    public A3DTextureMaterial[] TextureMaterials;
}