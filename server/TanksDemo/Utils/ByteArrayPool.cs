namespace Utils;

public static class ByteArrayPool
{
    private static readonly Queue<ByteArray> BigEndianPool = new();
    private static readonly Queue<ByteArray> LittleEndianPool = new();
    
    public static ByteArray Get(ByteEndian endian = ByteEndian.BigEndian)
    {
        Queue<ByteArray> pool = GetPool(endian);
        
        lock (pool)
        {
            if (pool.TryDequeue(out ByteArray? array))
            {
                return array;
            }
        }

        return new ByteArray(null, endian);
    }

    public static void Put(ByteArray array)
    {
        array.Clear();
        
        Queue<ByteArray> pool = GetPool(ByteEndian.BigEndian);

        lock (pool)
        {
            pool.Enqueue(array);
        }
    }

    private static Queue<ByteArray> GetPool(ByteEndian endian)
    {
        return (endian == ByteEndian.BigEndian ? BigEndianPool : LittleEndianPool);
    }
}