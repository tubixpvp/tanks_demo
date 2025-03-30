using System.IO.Compression;

namespace Utils;

public static class CompressionUtil
{
    public static byte[] UncompressZLib(byte[] bytes)
    {
        using MemoryStream inputStream = new MemoryStream(bytes);
        using ZLibStream zLibStream = new ZLibStream(inputStream, CompressionMode.Decompress);

        byte[] outputBuffer = new byte[zLibStream.Length];

        zLibStream.ReadExactly(outputBuffer, 0, outputBuffer.Length);

        return outputBuffer;
    }
}