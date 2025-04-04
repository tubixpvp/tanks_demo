using Network.Protocol;
using Utils;

namespace NetworkCommons.Channels.Spaces;

public class SpaceCommand(long objectId, long methodId)
{
    public long ObjectId => objectId;
    public long MethodId => methodId;

    public ByteArray DataBuffer { get; } = ByteArrayPool.Get();
    public NullMap NullMap { get; } = new NullMap();

    public void Dispose()
    {
        ByteArrayPool.Put(DataBuffer);
    }
}