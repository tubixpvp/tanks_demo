using System.IO.Compression;

namespace Utils;

public static class CompressionUtil
{
    public static byte[] UncompressZLib(byte[] bytes)
    {
        return OperateZLib(bytes, CompressionMode.Decompress);
    }

    public static byte[] CompressZLib(byte[] bytes)
    {
        return OperateZLib(bytes, CompressionMode.Compress);
    }

    private static byte[] OperateZLib(byte[] bytes, CompressionMode mode)
    {
        using MemoryStream inputStream = new MemoryStream(bytes);
        using ZLibStream zLibStream = new ZLibStream(inputStream, mode);

        byte[] outputBuffer = new byte[zLibStream.Length];

        zLibStream.ReadExactly(outputBuffer, 0, outputBuffer.Length);

        return outputBuffer;
    }
}