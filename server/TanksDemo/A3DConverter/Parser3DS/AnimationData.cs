using Utils.Maths;

namespace A3DConverter.Parser3DS;

public class AnimationData
{
    public string ObjectName;

    public ObjectData? Object3d;

    public int ParentIndex;

    public Vector3 Pivot;

    public Vector3 Position;

    public Vector3 Rotation;

    public Vector3 Scale;

    public bool IsInstance;
}