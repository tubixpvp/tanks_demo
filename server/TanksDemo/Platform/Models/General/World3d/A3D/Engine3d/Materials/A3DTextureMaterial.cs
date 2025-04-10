using System.Diagnostics.CodeAnalysis;
using Core.Generator;

namespace Platform.Models.General.World3d.A3D.Engine3d.Materials;

[ClientExport]
public class A3DTextureMaterial : A3DMaterial
{
    [MaybeNull] public A3DResourceLink? Texture;
}