namespace Utils;

public static class LongUtils
{
    private static readonly ByteArray _buffer = new();
    
    public static (int high, int low) GetLongHighLow(long input)
    {
        lock (_buffer)
        {
            _buffer.Clear();

            _buffer.WriteInt(input);
            _buffer.Position = 0;

            return (_buffer.ReadInt(), _buffer.ReadInt());
        }
    }
}