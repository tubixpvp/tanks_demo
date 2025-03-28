namespace Logging;

internal class Logger : ILogger
{
    public void Log(LogLevel level, string message)
    {
        //todo
        
        Console.WriteLine($"[{level}] {DateTime.Now.ToShortTimeString()} : {message}");
    }
}