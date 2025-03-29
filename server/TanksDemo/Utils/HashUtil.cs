using System.Security.Cryptography;

namespace Utils;

public static class HashUtil
{
    public static string GetBase64SHA256String(byte[] data)
    {
        using SHA256 sha256 = SHA256.Create();
        
        byte[] hash = sha256.ComputeHash(data);

        return Convert.ToBase64String(hash);
    }
}