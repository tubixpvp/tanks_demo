using Platform.Models.General.World3d;
using Utils.Maths;

namespace Platform.Utils;

public static class Vector3Util
{
    public static Vector3d ToVector3d(this Vector3 vec3)
    {
        return new Vector3d()
        {
            X = vec3.X,
            Y = vec3.Y,
            Z = vec3.Z
        };
    }

    public static void CopyFromVector3d(this Vector3 vec3, Vector3d vec3d)
    {
        vec3.X = vec3d.X;
        vec3.Y = vec3d.Y;
        vec3.Z = vec3d.Z;
    }
}