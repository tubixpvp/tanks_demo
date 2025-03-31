namespace Network.Protocol;

public class NullMap
{
    private const int SizeQuant = 8;
    
    private byte[] _map;
    
    private int _capacity;

    private int _readPosition;
    private int _size;

    public NullMap()
    {
        _map = new byte[SizeQuant];
        _size = 0;
        _readPosition = 0;
        _capacity = SizeQuant << 3;
    }
    public NullMap(int size)
    {
        Init(size);
    }
    public NullMap(int size, byte[] source)
    {
        Init(size);
        source.CopyTo(_map!, 0);
    }

    private void Init(int size)
    {
        _map = new byte[ConvertSize(size)];
        _size = size;
        _capacity = _map.Length << 3;
        _readPosition = 0;
    }

    public void Reset()
    {
        _readPosition = 0;
    }

    public void AddBit(bool isNull)
    {
        if (_size >= _capacity)
        {
            IncSize();
        }

        SetBit(_size, isNull);
        _size++;
    }

    public void Concat(NullMap otherMap)
    {
        for (int i = 0; i < otherMap.GetSize(); i++)
        {
            AddBit(otherMap.GetBit(i));
        }
    }

    public bool GetBit()
    {
        if (_readPosition >= _size)
        {
            throw new IndexOutOfRangeException();
        }

        bool res = GetBit(_readPosition);
        _readPosition++;
        return res;
    }

    public byte[] GetMap()
    {
        return _map;
    }

    public int GetSize()
    {
        return _size;
    }

    private bool GetBit(int position)
    {
        int targetByte = position >> 3;
        int targetBit = 7 ^ (position & 7);
        return (_map[targetByte] & (1 << targetBit)) != 0;
    }

    private void SetBit(int position, bool value)
    {
        int targetByte = position >> 3;
        int targetBit = 7 ^ (position & 7);
        if (value)
        {
            _map[targetByte] = (byte)(this._map[targetByte] | (1 << targetBit));
        }
    }

    private void IncSize()
    {
        byte[] newMap = new byte[_map.Length + SizeQuant];
        for (int i = 0; i < _map.Length; i++)
        {
            newMap[i] = _map[i];
        }

        _map = newMap;
        _capacity = _map.Length << 3;
    }

    private int ConvertSize(int sizeInBits)
    {
        int i = sizeInBits >> 3;
        int add = (sizeInBits & 0x07) == 0 ? 0 : 1;
        return i + add;
    }
}