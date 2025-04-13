using System.Text;
using Network.Protocol;
using Network.Session;
using NetworkCommons.Channels.Spaces;
using OSGI.Services;
using ProtocolEncoding;
using Utils;

namespace NetworkCommons.Channels.Control.Commands.Client;

internal class ProduceHashCommand(byte[] hashBytes) : IControlCommand
{
    [InjectService]
    private static SpaceChannelHandler SpaceChannelHandler;
    
    
    public const byte CommandID = 0;

    public byte CommandId => CommandID;
    
    public async Task Execute(ControlChannelHandler channelHandler, NetworkSession session)
    {
        string? sessionId = channelHandler.GetSessionId(session);

        if (sessionId != null)
        {
            return; //already inited as CONTROL session
        }
        
        sessionId = Encoding.UTF8.GetString(hashBytes);

        await SpaceChannelHandler.SetupAsSpaceSession(session, sessionId);
    }
    
}

[CustomCodec(typeof(ProduceHashCommand))]
class ProduceHashCommandCodec : ICustomCodec
{
    public object Decode(ByteArray input, NullMap nullMap)
    {
        byte[] hashBytes = input.ReadBytes(32);
        return new ProduceHashCommand(hashBytes);
    }

    public void Encode(object data, ByteArray output, NullMap nullMap)
    {
        throw new InvalidOperationException();
    }
}