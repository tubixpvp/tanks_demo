using Utils;
using Utils.Maths;

namespace A3DConverter.Parser3DS;

public sealed class Parser3DS
{
    private const int CHUNK_MAIN = 19789;
    private const int CHUNK_VERSION = 2;
    private const int CHUNK_SCENE = 15677;
    private const int CHUNK_ANIMATION = 45056;
    private const int CHUNK_OBJECT = 16384;
    private const int CHUNK_TRIMESH = 16640;
    private const int CHUNK_VERTICES = 16656;
    private const int CHUNK_FACES = 16672;
    private const int CHUNK_FACESMATERIAL = 16688;
    private const int CHUNK_FACESSMOOTH = 16720;
    private const int CHUNK_MAPPINGCOORDS = 16704;
    private const int CHUNK_TRANSFORMATION = 16736;
    private const int CHUNK_MATERIAL = 45055;

    
    private ByteArray _data;
    private Dictionary<string, ObjectData>? _objectDatas;
    private List<AnimationData>? _animationDatas;
    private Dictionary<string, MaterialData>? _materialDatas;


    public void Parse(byte[] buffer, string textureRootUrl = "", float positionScale = 1)
    {
        if (buffer.Length < 6)
            return;
        _data = new ByteArray(buffer, ByteEndian.LittleEndian);

        Parse3DSChunk((int)_data.Position, (int)_data.BytesAvailable);

        BuildContent();

        _data.Dispose();
    }

    public AnimationData[] AnimationDatas => _animationDatas!.ToArray();

    private void BuildContent()
    {
        if (_animationDatas != null && _objectDatas != null)
        {
            int animationsLength = _animationDatas.Count;
            int i = 0;
            while (i < animationsLength)
            {
                AnimationData animData = _animationDatas[i];
                string objectName = animData.ObjectName;
                ObjectData? objectData = _objectDatas[objectName];//
                if (objectData != null)
                {
                    int j = i + 1;
                    int objectCounter = 1;
                    while (j < animationsLength)
                    {
                        AnimationData animData2 = _animationDatas[j];
                        if (!animData2.IsInstance && objectName == animData2.ObjectName)
                        {
                            ObjectData instanceObject = new ObjectData();
                            string instanceObjectName = objectName + objectCounter++;
                            instanceObject.Name = instanceObjectName;
                            _objectDatas[instanceObjectName] = instanceObject;
                            animData2.ObjectName = instanceObjectName;
                            instanceObject.Vertices = objectData.Vertices;
                            instanceObject.UVs = objectData.UVs;
                            instanceObject.Faces = objectData.Faces;
                            instanceObject.SmoothingGroups = objectData.SmoothingGroups;
                            instanceObject.Surfaces = objectData.Surfaces;
                            instanceObject.a = objectData.a;
                            instanceObject.b = objectData.b;
                            instanceObject.c = objectData.c;
                            instanceObject.d = objectData.d;
                            instanceObject.e = objectData.e;
                            instanceObject.f = objectData.f;
                            instanceObject.g = objectData.g;
                            instanceObject.h = objectData.h;
                            instanceObject.i = objectData.i;
                            instanceObject.j = objectData.j;
                            instanceObject.k = objectData.k;
                            instanceObject.l = objectData.l;
                        }

                        j++;
                    }
                }

                animData.Object3d = objectData;

                i++;
            }
        }
    }

    private void Parse3DSChunk(int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        _data.Position = position;
        switch (chunk.Id)
        {
            case CHUNK_MAIN:
                ParseMainChunk(chunk.DataPosition, chunk.DataSize);
                break;
        }

        Parse3DSChunk(chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private ChunkInfo ReadChunkInfo(int position)
    {
        _data.Position = position;
        ChunkInfo chunk = new ChunkInfo();
        chunk.Id = _data.ReadUShort();
        chunk.Size = (int)_data.ReadUInt();
        chunk.DataSize = chunk.Size - 6;
        chunk.DataPosition = (int)_data.Position;
        chunk.NextChunkPosition = position + chunk.Size;
        return chunk;
    }

    private void ParseMainChunk(int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case CHUNK_VERSION:
                break;
            case CHUNK_SCENE:
                Parse3DChunk(chunk.DataPosition, chunk.DataSize);
                break;
            case CHUNK_ANIMATION:
                ParseAnimationChunk(chunk.DataPosition, chunk.DataSize);
                break;
        }

        ParseMainChunk(chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void Parse3DChunk(int position, int bytesAvailable)
    {
        ChunkInfo chunk;
        for (; bytesAvailable >= 6; position = chunk.NextChunkPosition, bytesAvailable -= chunk.Size)
        {
            chunk = ReadChunkInfo(position);
            switch (chunk.Id)
            {
                case CHUNK_MATERIAL:
                    MaterialData material = new MaterialData();
                    ParseMaterialChunk(material, chunk.DataPosition, chunk.DataSize);
                    continue;
                case CHUNK_OBJECT:
                    ParseObject(chunk);
                    continue;
                default:
                    continue;
            }
        }
    }

    private void ParseMaterialChunk(MaterialData material, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case 40960:
                ParseMaterialName(material);
                break;
            case 40976:
                break;
            case 40992:
                _data.Position = chunk.DataPosition + 6;
                material.Color = (_data.ReadSByte() << 16) + (_data.ReadSByte() << 8) +
                               _data.ReadSByte();
                break;
            case 41008:
                break;
            case 41024:
                _data.Position = chunk.DataPosition + 6;
                material.Glossiness = _data.ReadUShort();
                break;
            case 41025:
                _data.Position = chunk.DataPosition + 6;
                material.Specular = _data.ReadUShort();
                break;
            case 41040:
                _data.Position = chunk.DataPosition + 6;
                material.Transparency = _data.ReadUShort();
                break;
            case 41472:
                material.DiffuseMap = new MapData();
                ParseMapChunk(material.Name, material.DiffuseMap, chunk.DataPosition, chunk.DataSize);
                break;
            case 41786:
                break;
            case 41488:
                material.OpacityMap = new MapData();
                ParseMapChunk(material.Name, material.OpacityMap, chunk.DataPosition, chunk.DataSize);
                break;
            case 41520:
                break;
            case 41788:
                break;
            case 41476:
                break;
            case 41789:
                break;
            case 41504:
                break;
        }

        ParseMaterialChunk(material, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void ParseMaterialName(MaterialData material)
    {
        _materialDatas ??= new Dictionary<string, MaterialData>();

        material.Name = GetString(_data.Position);
        _materialDatas[material.Name] = material;
    }

    private string GetString(long position)
    {
        _data.Position = position;
        
        string result = "";
        
        byte b;
        while ((b = _data.ReadByte()) != 0)
        {
            result += (char)b;
        }

        return result;
    }

    private void ParseMapChunk(string materialName, MapData mapData, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case 41728:
                mapData.FileName = GetString(chunk.DataPosition).ToLower();
                break;
            case 41809:
                break;
            case 41812:
                mapData.ScaleU = _data.ReadFloat();
                break;
            case 41814:
                mapData.ScaleV = _data.ReadFloat();
                break;
            case 41816:
                mapData.OffsetU = _data.ReadFloat();
                break;
            case 41818:
                mapData.OffsetV = _data.ReadFloat();
                break;
            case 41820:
                mapData.Rotation = _data.ReadFloat();
                break;
        }

        ParseMapChunk(materialName, mapData, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void ParseObject(ChunkInfo chunk)
    {
        _objectDatas ??= new Dictionary<string, ObjectData>();

        ObjectData objectData = new ObjectData();
        objectData.Name = GetString(chunk.DataPosition);
        _objectDatas[objectData.Name] = objectData;
        
        int nameBytesLength = objectData.Name.Length + 1;
        ParseObjectChunk(objectData, chunk.DataPosition + nameBytesLength, chunk.DataSize - nameBytesLength);
    }

    private void ParseObjectChunk(ObjectData objectData, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case CHUNK_TRIMESH:
                ParseMeshChunk(objectData, chunk.DataPosition, chunk.DataSize);
                break;
            case 17920:
                break;
            case 18176:
                break;
        }

        ParseObjectChunk(objectData, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void ParseMeshChunk(ObjectData objectData, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case CHUNK_VERTICES:
                ParseVertices(objectData);
                break;
            case CHUNK_MAPPINGCOORDS:
                ParseUVs(objectData);
                break;
            case CHUNK_TRANSFORMATION:
                ParseMatrix(objectData);
                break;
            case CHUNK_FACES:
                ParseFaces(objectData, chunk);
                break;
        }

        ParseMeshChunk(objectData, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void ParseVertices(ObjectData objectData)
    {
        int verticesNum = _data.ReadUShort();
        objectData.Vertices = new float[verticesNum * 3];
        int i = 0;
        int vertexIndex = 0;
        while (i < verticesNum)
        {
            objectData.Vertices[vertexIndex++] = _data.ReadFloat();
            objectData.Vertices[vertexIndex++] = _data.ReadFloat();
            objectData.Vertices[vertexIndex++] = _data.ReadFloat();
            i++;
        }
    }

    private void ParseUVs(ObjectData objectData)
    {
        int size = _data.ReadUShort();
        objectData.UVs = new float[size * 2];
        int i = 0;
        int uvIndex = 0;
        while (i < size)
        {
            objectData.UVs[uvIndex++] = _data.ReadFloat();
            objectData.UVs[uvIndex++] = _data.ReadFloat();
            i++;
        }
    }

    private void ParseMatrix(ObjectData objectData)
    {
        objectData.a = _data.ReadFloat();
        objectData.e = _data.ReadFloat();
        objectData.i = _data.ReadFloat();
        objectData.b = _data.ReadFloat();
        objectData.f = _data.ReadFloat();
        objectData.j = _data.ReadFloat();
        objectData.c = _data.ReadFloat();
        objectData.g = _data.ReadFloat();
        objectData.k = _data.ReadFloat();
        objectData.d = _data.ReadFloat();
        objectData.h = _data.ReadFloat();
        objectData.l = _data.ReadFloat();
    }

    private void ParseFaces(ObjectData objectData, ChunkInfo chunk)
    {
        int facesNum = _data.ReadUShort();
        objectData.Faces = new int[facesNum * 3];
        objectData.SmoothingGroups = new uint[facesNum];
        int i = 0;
        int faceIndex = 0;
        while (i < facesNum)
        {
            objectData.Faces[faceIndex++] = _data.ReadUShort();
            objectData.Faces[faceIndex++] = _data.ReadUShort();
            objectData.Faces[faceIndex++] = _data.ReadUShort();
            _data.Position += 2;
            i++;
        }

        int offset = 2 + 8 * facesNum;
        ParseFacesChunk(objectData, chunk.DataPosition + offset, chunk.DataSize - offset);
    }

    private void ParseFacesChunk(ObjectData objectData, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case CHUNK_FACESMATERIAL:
                ParseSurface(objectData);
                break;
            case CHUNK_FACESSMOOTH:
                ParseSmoothingGroups(objectData);
                break;
        }

        ParseFacesChunk(objectData, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private void ParseSurface(ObjectData objectData)
    {
        objectData.Surfaces ??= new Dictionary<string, int[]>();

        string surfName = GetString(_data.Position);
        int surfacesNum = _data.ReadUShort();
        int[] indices = new int[surfacesNum];
        objectData.Surfaces[surfName] = indices;
        int i = 0;
        while (i < surfacesNum)
        {
            indices[i] = _data.ReadUShort();
            i++;
        }
    }

    private void ParseSmoothingGroups(ObjectData param1)
    {
        int length = param1.Faces.Length / 3;
        int i = 0;
        while (i < length)
        {
            param1.SmoothingGroups[i] = _data.ReadUInt();
            i++;
        }
    }


    private void ParseAnimationChunk(int position, int bytesAvailable)
    {
        ChunkInfo chunk;
        for (; bytesAvailable >= 6; position = chunk.NextChunkPosition, bytesAvailable -= chunk.Size)
        {
            chunk = ReadChunkInfo(position);
            switch (chunk.Id)
            {
                case 45057:
                case 45058:
                case 45059:
                case 45060:
                case 45061:
                case 45062:
                case 45063:
                    _animationDatas ??= new List<AnimationData>();

                    AnimationData animData = new AnimationData();
                    _animationDatas.Add(animData);
                    ParseObjectAnimationChunk(animData, chunk.DataPosition, chunk.DataSize);
                    continue;
                case 45064:
                    continue;
                default:
                    continue;
            }
        }
    }

    private void ParseObjectAnimationChunk(AnimationData animData, int position, int bytesAvailable)
    {
        if (bytesAvailable < 6)
        {
            return;
        }

        ChunkInfo chunk = ReadChunkInfo(position);
        switch (chunk.Id)
        {
            case 45072:
                animData.ObjectName = GetString(_data.Position);
                _data.Position += 4;
                animData.ParentIndex = _data.ReadUShort();
                break;
            case 45073:
                animData.ObjectName = GetString(_data.Position);
                break;
            case 45075:
                animData.Pivot = new Vector3(_data.ReadFloat(), _data.ReadFloat(), _data.ReadFloat());
                break;
            case 45088:
                _data.Position += 20;
                animData.Position = new Vector3(_data.ReadFloat(), _data.ReadFloat(), _data.ReadFloat());
                break;
            case 45089:
                _data.Position += 20;
                animData.Rotation = GetRotationFrom3DsAngleAxis(_data.ReadFloat(), _data.ReadFloat(),
                    _data.ReadFloat(), _data.ReadFloat());
                break;
            case 45090:
                _data.Position += 20;
                animData.Scale = new Vector3(_data.ReadFloat(), _data.ReadFloat(), _data.ReadFloat());
                break;
        }

        ParseObjectAnimationChunk(animData, chunk.NextChunkPosition, bytesAvailable - chunk.Size);
    }

    private Vector3 GetRotationFrom3DsAngleAxis(float angle, float x, float y, float z)
    {
        Vector3 res = new Vector3();
        float s = MathF.Sin(angle);
        float c = MathF.Cos(angle);
        float t = 1 - c;
        float k = x * y * t + z * s;
        float half;
        if (k >= 1)
        {
            half = angle / 2;
            res.Z = -2 * MathF.Atan2(x * MathF.Sin(half), MathF.Cos(half));
            res.Y = -MathF.PI / 2;
            res.X = 0;
            return res;
        }

        if (k <= -1)
        {
            half = angle / 2;
            res.Z = 2 * MathF.Atan2(x * MathF.Sin(half), MathF.Cos(half));
            res.Y = MathF.PI / 2;
            res.X = 0;
            return res;
        }

        res.Z = -MathF.Atan2(y * s - x * z * t, 1 - (y * y + z * z) * t);
        res.Y = -MathF.Asin(x * y * t + z * s);
        res.X = -MathF.Atan2(x * s - y * z * t, 1 - (x * x + z * z) * t);
        return res;
    }
}