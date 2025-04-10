using System.Text.RegularExpressions;
using A3DConverter.Parser3DS;
using Platform.Models.General.World3d.A3D;
using Platform.Models.General.World3d.A3D.Engine3d.Core;
using Utils.Maths;

namespace A3DConverter;

public class Converter3DSToA3D
{

    private static readonly Regex MobilityRegex = new("(\\w+\\|)?(-?\\d+)#", RegexOptions.Compiled);

    public A3D Convert(byte[] input3ds)
    {
        Parser3DS.Parser3DS parser = new Parser3DS.Parser3DS();

        parser.Parse(input3ds);

        A3D a3d = new A3D();

        a3d.RootObject = new A3DObject3D()
        {
            Name = "rootObject",
            Mobility = 0,
            Coords = new A3DVector3D(),
            Rotation = new A3DVector3D(),
            Scale = new A3DVector3D() {X=1,Y=1,Z=1},
            ChildObjects = []
        };

        List<A3DMesh> meshes = new();
        
        foreach (AnimationData animData in parser.AnimationDatas)
        {
            ObjectData objData = animData.Object3d!;

            
            int verticesNum = objData.Vertices.Length/3;
            A3DVector3D[] vertices = new A3DVector3D[verticesNum];
            A3DVector2D[] uvs = new A3DVector2D[verticesNum];

            int vertexIndex = 0;
            int uvIndex = 0;
            
            for (int i = 0; i < verticesNum; i++)
            {
                vertices[i] = new A3DVector3D()
                {
                    X = objData.Vertices[vertexIndex++],
                    Y = objData.Vertices[vertexIndex++],
                    Z = objData.Vertices[vertexIndex++]
                };
                uvs[i] = new A3DVector2D()
                {
                    X = objData.UVs[uvIndex++],
                    Y = objData.UVs[uvIndex++]
                };
            }
            

            int facesLength = objData.Faces.Length;
            A3DFace[] faces = new A3DFace[facesLength / 3];

            int faceIndex = 0;
            for (int i = 0; i < facesLength; i+= 3)
            {
                int face1 = objData.Faces[i];
                int face2 = objData.Faces[i+1];
                int face3 = objData.Faces[i+2];
                
                faces[faceIndex] = new A3DFace()
                {
                    Vertices = [face1,face2,face3],
                    AUV = uvs[face1],
                    BUV = uvs[face2],
                    CUV = uvs[face3]
                };
                
                faceIndex++;
            }
            

            A3DSurface[] surfaces = new A3DSurface[objData.Surfaces!.Count];
            int surfaceIndex = 0;
            foreach (int[] facesIndices in objData.Surfaces!.Values)
            {
                surfaces[surfaceIndex] = new A3DSurface()
                {
                    Faces = facesIndices,
                    //todo
                };
                
                surfaceIndex++;
            }

            int mobility = GetMobility(objData);
            
            meshes.Add(new A3DMesh()
            {
                Vertices = vertices,
                Faces = faces,
                Surfaces = surfaces,

                Name = objData.Name,
                Mobility = mobility,
                Coords = ConvertVector3(animData.Position),
                Rotation = ConvertVector3(animData.Rotation),
                Scale = ConvertVector3(animData.Scale),

                ChildObjects = [],
                ChildMeshes = []
            });
        }

        a3d.RootObject.ChildMeshes = meshes.ToArray();
        a3d.FillMaterials = [];
        a3d.TextureMaterials = [];

        return a3d;
    }

    private static A3DVector3D ConvertVector3(Vector3 vec3)
    {
        return new A3DVector3D()
        {
            X = vec3.X,
            Y = vec3.Y,
            Z = vec3.Z
        };
    }

    private static int GetMobility(ObjectData objData)
    {
        Match match = MobilityRegex.Match(objData.Name);
        if (match.Success)
        {
            objData.Name = objData.Name.Replace(match.Value, "");
            return int.Parse(match.Groups[2].Value);
        }
        return 0;
    }
    
}