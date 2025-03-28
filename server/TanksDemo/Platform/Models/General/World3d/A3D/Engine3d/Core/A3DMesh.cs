using Core.Generator;

namespace Platform.Models.General.World3d.A3D.Engine3d.Core;

[ClientExport]
public class A3DMesh : A3DObject3D
{
    public A3DVector3D[] Vertices;
    public A3DFace[] Faces;
    public A3DSurface[] Surfaces;
}