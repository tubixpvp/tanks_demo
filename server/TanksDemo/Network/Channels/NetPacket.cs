using Network.Protocol;
using Utils;

namespace Network.Channels;

public class NetPacket(ByteArray packetBuffer, NullMap nullMap)
{
    public readonly ByteArray PacketBuffer = packetBuffer;

    public readonly NullMap NullMap = nullMap;
}