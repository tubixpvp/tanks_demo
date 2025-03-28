using System.Diagnostics.CodeAnalysis;
using Core.Generator;
using Platform.Models.General.World3d.A3D.Engine3d.Materials;

namespace Platform.Models.General.World3d.A3D.Engine3d.Core;

[ClientExport]
public class A3DSurface
{
    public int[] Faces;

    public int MaterialIndex = -1;

    [MaybeNull] public A3DMaterialType? MaterialType;
}