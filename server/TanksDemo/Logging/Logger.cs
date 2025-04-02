namespace Logging;

internal class Logger(Type senderType) : ILogger
{
    private static readonly Dictionary<LogLevel, ConsoleColor> LevelToColor = new()
    {
        [LogLevel.Info] = Console.ForegroundColor, //default color
        [LogLevel.Debug] = ConsoleColor.Green,
        [LogLevel.Warn] = ConsoleColor.Yellow,
        [LogLevel.Error] = ConsoleColor.Red
    };
    
    public void Log(LogLevel level, string message)
    {
        ConsoleColor colorBefore = Console.ForegroundColor;
        
        Console.ForegroundColor = LevelToColor[level];
        
        Console.WriteLine($"[{level}] [{senderType.Name}] {DateTime.Now.ToString("HH:mm:ss")} : {message}");

        Console.ForegroundColor = colorBefore;
    }
}