using Core.Generator;

namespace Platform.Models.General.World3d.A3D.Engine3d.Core;

[ClientExport]
public class A3DObject3D
{
    public string Name;

    public int Mobility;
    
    public A3DVector3D Coords;
    public A3DVector3D Rotation;
    public A3DVector3D Scale;

    public A3DObject3D[] ChildObjects;

    public A3DMesh[] ChildMeshes;
}