namespace Logging;

public interface ILogger
{
    public void Log(LogLevel level, string message);
}