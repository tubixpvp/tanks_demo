namespace Utils;

public class CancellableFunction
{
    private readonly Action _function;

    private readonly SimpleCancelToken _cancelToken;
    
    
    public CancellableFunction(Action func, SimpleCancelToken cancelToken)
    {
        _function = func;
        _cancelToken = cancelToken;
    }

    public void Call()
    {
        if (_cancelToken.Cancelled)
            return;
        _function();
    }
}