namespace Utils;

public class SimpleCancelToken
{
    public bool Cancelled => _cancelled;

    private bool _cancelled;


    public void Cancel()
    {
        _cancelled = true;
    }

    public void Reset()
    {
        _cancelled = false;
    }
}