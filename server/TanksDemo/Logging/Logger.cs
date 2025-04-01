namespace Logging;

internal class Logger(Type senderType) : ILogger
{
    public void Log(LogLevel level, string message)
    {
        //todo
        
        Console.WriteLine($"[{level}] [{senderType.Name}] {DateTime.Now.ToString("HH:mm:ss")} : {message}");
    }
}