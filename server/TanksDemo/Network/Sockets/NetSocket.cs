using System.Net;
using System.Net.Sockets;
using Network.Utils;
using Utils;

namespace Network.Sockets;

public class NetSocket
{
    public string IPAddress { get; }

    
    private readonly Socket _socket;


    private readonly SocketAsyncEventArgs _socketEvents = new();
    
    private readonly byte[] _byteBuffer = new byte[512];
    
    
    private readonly ByteArray _buffer = new();

    private readonly ByteArray _packetBuffer = new();

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
            ProgressData(socketEvents.BytesTransferred);
        }
        if (_readingActive)
        {
            BeginRead();
        }
    }

    private void ProgressData(int bytesCount)
    {
        _buffer.Position = _buffer.Length;
        _buffer.WriteBytes(_byteBuffer, 0, bytesCount);

        _buffer.Position = _packetCursor;

        while (_buffer.BytesAvailable > 0)
        {
            if (!PacketUtil.UnwrapPacket(_buffer, _packetBuffer))
                return;
            _packetBuffer.Position = 0;
            
            //
            
            _packetBuffer.Clear();
        }
    }
}