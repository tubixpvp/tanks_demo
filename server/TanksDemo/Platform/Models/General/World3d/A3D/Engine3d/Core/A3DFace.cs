using System.Diagnostics.CodeAnalysis;
using Core.Generator;

namespace Platform.Models.General.World3d.A3D.Engine3d.Core;

[ClientExport]
public class A3DFace
{
    public int[] Vertices;

    [MaybeNull] public A3DVector2D? AUV;
    [MaybeNull] public A3DVector2D? BUV;
    [MaybeNull] public A3DVector2D? CUV;
}