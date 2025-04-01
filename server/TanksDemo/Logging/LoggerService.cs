using System.Collections.Concurrent;
using OSGI.Services;

namespace Logging;

[Service]
public class LoggerService
{
    private readonly ConcurrentDictionary<Type, ILogger> _loggers = new ();
    
    
    public ILogger GetLogger(Type type)
    {
        if (_loggers.TryGetValue(type, out var logger))
            return logger;
        logger = new Logger(type);
        _loggers.TryAdd(type, logger);
        return logger;
    }
}