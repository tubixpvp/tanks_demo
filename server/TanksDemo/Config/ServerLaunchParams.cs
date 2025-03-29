using Utils;

namespace Config;

public static class ServerLaunchParams
{
    private static ParametersUtil _launchParams;
    
    public static void Init(ParametersUtil launchParams)
    {
        _launchParams = launchParams;
    }

    public static ParametersUtil GetLaunchParams()
    {
        return _launchParams;
    }
}