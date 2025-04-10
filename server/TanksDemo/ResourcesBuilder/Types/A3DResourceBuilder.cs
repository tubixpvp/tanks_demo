using GameResources;

namespace ResourcesBuilder.Types;

internal class A3DResourceBuilder : ResourceTypeBuilderBase
{
    private static readonly string[] FileNames = ["model", "object"];
    
    private static readonly string[] FileExtensionsA3D = ["a3d"];
    private static readonly string[] FileExtensions3DS = ["3ds"];


    public override async Task<string> CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        byte[]? data3ds = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensions3DS);

        string format;
        if (data3ds != null)
        {
            outputFiles["object.3ds"] = data3ds;
            format = "3ds";
        }
        else
        {
            byte[] dataA3d = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensionsA3D)
                             ?? throw new Exception("Model 3d file not found in: " + resourceInfo.FilesPath);
            outputFiles["object.a3d"] = dataA3d;
            format = "a3d";
        }

        return format;
    }

    //private const string OutputFileName = "object.a3d";

    /*public override async Task CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        string resourcePath = resourceInfo.FilesPath;

        byte[]? a3dData = await LoadFirst(resourcePath, FileNames, FileExtensionsA3D);

        if (a3dData != null)
        {
            outputFiles.Add(OutputFileName, a3dData);
            return;
        }

        byte[] bytes3ds = await LoadFirst(resourcePath, FileNames, FileExtensions3DS)
                          ?? throw new Exception("Model 3d file not found in: " + resourcePath);

        A3D a3d = new Converter3DSToA3D().Convert(bytes3ds);
        
        await File.WriteAllTextAsync(Path.Combine(resourceInfo.FilesPath, "model.json"), JsonConvert.SerializeObject(a3d, Formatting.Indented));


        ByteArray encodeBuffer = new();
        NullMap nullMap = new();

        GeneralDataEncoder.CodecsRegistry = new();
        GeneralDataEncoder.Encode(a3d, encodeBuffer, nullMap);

        a3dData = encodeBuffer.ToArray();
        encodeBuffer.Clear();

        NullMapUtil.EncodeNullMap(nullMap, encodeBuffer);
        encodeBuffer.WriteBytes(a3dData);
        encodeBuffer.Position = 0;
        
        ByteArray output = new();
        PacketUtil.WrapPacket(encodeBuffer, output, true);


        outputFiles.Add(OutputFileName, output.ToArray());
    }*/

    /*public override async Task CollectFiles(ResourceInfo resourceInfo, string[] resourceFiles, Dictionary<string, byte[]> outputFiles)
    {
        byte[] a3dBytes = outputFiles["object.a3d"] = await LoadFirst(resourceInfo.FilesPath, FileNames, FileExtensions)
                                   ?? throw new Exception("3D model not found in " + resourceInfo.FilesPath);

        //debug:
        ByteArray packetBytes = new();
        PacketUtil.UnwrapPacket(new ByteArray(a3dBytes), packetBytes);

        packetBytes.Position = 0;

        NullMap nullMap = NullMapUtil.DecodeNullMap(packetBytes);

        GeneralDataDecoder.CodecsRegistry = new();
        A3D a3d = GeneralDataDecoder.Decode<A3D>(packetBytes, nullMap)!;

        await File.WriteAllTextAsync(Path.Combine(resourceInfo.FilesPath, "model.json"), JsonConvert.SerializeObject(a3d, Formatting.Indented));
    }*/
    
}