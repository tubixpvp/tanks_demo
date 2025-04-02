using Network.Protocol;
using Network.Session;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Server;

internal sealed class HashResponseCommand(byte[] hashBytes) : IControlCommand
{
    public byte CommandId => 2;


    public readonly byte[] HashBytes = hashBytes;
    
    public Task Execute(ControlCommandChannelHandler channelHandler, NetworkSession session)
    {
        throw new InvalidOperationException();
    }
}

[CustomCodec(typeof(HashResponseCommand))]
internal sealed class HashResponseCommandCodec : ICustomCodec
{
    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        output.WriteBytes(((HashResponseCommand)data).HashBytes);
    }
    
    public object Decode(ByteArray input, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}