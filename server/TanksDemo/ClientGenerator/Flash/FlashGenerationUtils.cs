namespace ClientGenerator.Flash;

internal static class FlashGenerationUtils
{
    public static string GetDirectoryByNamespace(string nameSpace)
    {
        return string.Join(Path.DirectorySeparatorChar, nameSpace.ToLower().Split('.'));
    }
}