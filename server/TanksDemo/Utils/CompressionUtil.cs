using System.IO.Compression;

namespace Utils;

public static class CompressionUtil
{
    public static byte[] CompressZLib(byte[] data)
    {
        using MemoryStream memoryStream = new MemoryStream();
        using (ZLibStream deflateStream = new ZLibStream(memoryStream, CompressionMode.Compress))
        {
            deflateStream.Write(data, 0, data.Length);
        }
        return memoryStream.ToArray();
    }
    public static byte[] DecompressZLib(byte[] data)
    {
        using MemoryStream decompressedStream = new MemoryStream();
        using (MemoryStream compressStream = new MemoryStream(data))
        {
            using (ZLibStream deflateStream = new ZLibStream(compressStream, CompressionMode.Decompress))
            {
                deflateStream.CopyTo(decompressedStream);
            }
        }
        return decompressedStream.ToArray();
    }
}