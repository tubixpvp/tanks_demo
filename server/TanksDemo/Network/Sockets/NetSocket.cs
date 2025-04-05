using System.Net;
using System.Net.Sockets;
using System.Text;
using Logging;
using Network.Channels;
using Network.Protocol;
using OSGI.Services;
using Utils;

namespace Network.Sockets;

public class NetSocket
{
    [InjectService]
    private static LoggerService LoggerService;
    
    public string IPAddress { get; }

    internal event PacketCallbackFunc? OnPacketReceived;
    internal event Func<Task>? OnDisconnected;
    internal event Action<Exception>? OnError;

    
    private readonly Socket _socket;
    
    private readonly byte[] _byteBuffer = new byte[512];
    
    
    private readonly ByteArray _buffer = new();

    private readonly ByteArray _packetBuffer = new();

    private readonly ByteArray _packetDataBuffer = new();


    private readonly ByteArray _sendBuffer = new();

    private readonly ByteArray _sendEncodeBuffer = new();
    

    private long _packetCursor = 0;
    

    private bool _readingActive = false;

    private bool _disconnected = false;
    
    internal NetSocket(Socket socket)
    {
        _socket = socket;
        
        IPAddress = (socket.RemoteEndPoint as IPEndPoint)!.Address.ToString();
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

    public async Task SendPacket(NetPacket packet, bool forceCompress = false)
    {
        byte[] data;
        lock (_sendBuffer)
        {
            _sendEncodeBuffer.Clear();

            NullMapUtil.EncodeNullMap(packet.NullMap, _sendEncodeBuffer);
            _sendEncodeBuffer.WriteBytes(packet.PacketBuffer);

            _sendEncodeBuffer.Position = 0;

            _sendBuffer.Clear();
            
            PacketUtil.WrapPacket(_sendEncodeBuffer, _sendBuffer, forceCompress);

            data = _sendBuffer.ToArray();
        }
        
        await _socket.SendAsync(data, SocketFlags.None);
    }

    private void BeginRead()
    {
        if(!_readingActive)
            return;
        try
        {
            _socket.BeginReceive(_byteBuffer, 0, _byteBuffer.Length, SocketFlags.None, OnReceiveEnd, null);
        }
        catch (Exception e)
        {
            OnSocketError(e);
        }
    }

    private void OnReceiveEnd(IAsyncResult result)
    {
        int bytesCount;
        try
        {
            bytesCount = _socket.EndReceive(result);
        }
        catch (Exception e)
        {
            OnSocketError(e);
            return;
        }

        if (bytesCount == 0)
        {
            Disconnect();
            return;
        }
        
        _buffer.Position = _buffer.Length;
        _buffer.WriteBytes(_byteBuffer, 0, bytesCount);
        
        ProgressData(BeginRead);
    }

    private void ProgressData(Action callback)
    {
        _buffer.Position = _packetCursor;

        if (_buffer.BytesAvailable == 0)
        {
            _packetCursor = 0;
            
            _buffer.Clear();
            
            callback();
            return;
        }

        if (IsPolicyRequest())
        {
            SendPolicyData();
            return; //policy connection usually closes right after receiving the policy data, so no need to start the reading again
        }

        _packetBuffer.Clear();

        if (!PacketUtil.UnwrapPacket(_buffer, _packetBuffer))
        {
            callback();
            return;
        }

        _packetCursor = _buffer.Position;

        
        _packetBuffer.Position = 0;

        NullMap nullMap = NullMapUtil.DecodeNullMap(_packetBuffer);
        
        _packetDataBuffer.Clear();
        _packetDataBuffer.WriteBytes(_packetBuffer.ReadBytes(_packetBuffer.BytesAvailable));
        

        NetPacket packet = new NetPacket(_packetDataBuffer, nullMap);
        
        Task? task = OnPacketReceived?.Invoke(packet);

        if (task != null)
        {
            SafeTask.AddListeners(task, OnSocketProtocolError);
            
            task.ContinueWith(_ => ProgressData(callback));
        }
        else
        {
            ProgressData(callback);
        }
    }

    private bool IsPolicyRequest()
    {
        if (_buffer.BytesAvailable < 23)
            return false;
        
        long posBefore = _buffer.Position;

        byte firstByte = _buffer.ReadByte();
        if (firstByte == 60)
        {
            _buffer.Position = posBefore;
            
            StringBuilder requestBuilder = new();
            
            byte b = _buffer.ReadByte();
            while (b != 0)
            {
                requestBuilder.Append((char)b);
                b = _buffer.ReadByte();
            }
            
            string request = requestBuilder.ToString();

            return request.Contains(PolicyUtil.PolicyFileRequest);
        }
        
        _buffer.Position = posBefore;

        return false;
    }

    private void SendPolicyData()
    {
        //Console.WriteLine("Sending policy: " + Encoding.UTF8.GetString(PolicyUtil.PolicyData));
        try
        {
            _socket.BeginSend(PolicyUtil.PolicyData, 0, PolicyUtil.PolicyData.Length, SocketFlags.None,
                OnPolicyDataSent, null);
        }
        catch (Exception e)
        {
            OnSocketError(e);
        }
    }
    private void OnPolicyDataSent(IAsyncResult result)
    {
        try
        {
            _socket.EndSend(result);

            Disconnect();
        }
        catch (Exception e)
        {
            OnSocketError(e);
        }
    }

    private void OnSocketError(Exception e)
    {
        Console.WriteLine("Socket error: " + e);
        
        Disconnect();
    }

    private void OnSocketProtocolError(Exception e)
    {
        OnError?.Invoke(e);
    }

    public void Disconnect()
    {
        if (_disconnected)
            return;
        
        _readingActive = false;
        
        try
        {
            _socket.Close();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }

        _disconnected = true;
        
        Task? task = OnDisconnected?.Invoke();

        if (task != null)
        {
            SafeTask.AddListeners(task, OnSocketProtocolError);
            
            task.ContinueWith(_ => OnDisconnectedEventsDone());
        }
        else
        {
            OnDisconnectedEventsDone();
        }

    }

    private void OnDisconnectedEventsDone()
    {
        _buffer.Dispose();
        _packetBuffer.Dispose();
        //_packetDataBuffer.Dispose();

        OnPacketReceived = null;
        OnDisconnected = null;
    }
    
    internal delegate Task PacketCallbackFunc(NetPacket packet);
    
}