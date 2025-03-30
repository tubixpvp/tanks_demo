using System.Net;
using System.Net.Sockets;
using Network.Channels;
using Network.Protocol;
using Utils;

namespace Network.Sockets;

public class NetSocket
{
    public string IPAddress { get; }

    internal event PacketCallbackFunc OnPacketReceived;

    
    private readonly Socket _socket;


    private readonly SocketAsyncEventArgs _socketEvents = new();
    
    private readonly byte[] _byteBuffer = new byte[512];
    
    
    private readonly ByteArray _buffer = new();

    private readonly ByteArray _packetBuffer = new();

    private readonly ByteArray _packetDataBuffer = new();

    private long _packetCursor = 0;
    

    private bool _readingActive = false;
    
    internal NetSocket(Socket socket)
    {
        _socket = socket;
        
        IPAddress = (socket.RemoteEndPoint as IPEndPoint)!.Address.ToString();

        _socketEvents.SetBuffer(_byteBuffer, 0, _byteBuffer.Length);
        _socketEvents.Completed += OnReadEnd;
    }

    public void StartReading()
    {
        if (_readingActive)
        {
            throw new Exception("Reading process is already started");
        }
        _readingActive = true;
        BeginRead();
    }

    private void BeginRead()
    {
        if(!_readingActive)
            return;
        _socket.ReceiveAsync(_socketEvents);
    }

    private void OnReadEnd(object? sender, SocketAsyncEventArgs socketEvents)
    {
        if (socketEvents.SocketError != SocketError.Success)
        {
            //todo handle error
            return;
        }
        if (socketEvents.BytesTransferred > 0)
        {
            _buffer.Position = _buffer.Length;
            _buffer.WriteBytes(_byteBuffer, 0, socketEvents.BytesTransferred);
            
            ProgressData(BeginRead);
        }
        else
        {
            BeginRead();
        }
    }

    private void ProgressData(Action callback)
    {
        _buffer.Position = _packetCursor;

        if (_buffer.BytesAvailable == 0)
        {
            _buffer.Clear();
            
            callback();
            return;
        }

        _packetBuffer.Clear();

        if (!PacketUtil.UnwrapPacket(_buffer, _packetBuffer))
        {
            callback();
            return;
        }

        _packetCursor = _buffer.Position;
        

        NullMap nullMap = new NullMap(); //TODO: decode
        
        _packetDataBuffer.Clear();
        _packetDataBuffer.WriteBytes(_packetBuffer.ReadBytes(_packetBuffer.BytesAvailable));

        NetPacket packet = new NetPacket(_packetDataBuffer, nullMap);
        
        Task? task = OnPacketReceived?.Invoke(packet);

        if (task != null && !task.IsCompleted)
        {
            task.ContinueWith(_ => ProgressData(callback));
        }
        else
        {
            ProgressData(callback);
        }
    }
    
    internal delegate Task PacketCallbackFunc(NetPacket packet);
}