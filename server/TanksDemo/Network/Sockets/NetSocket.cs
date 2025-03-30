using System.Net;
using System.Net.Sockets;

namespace Network.Sockets;

public class NetSocket
{
    public string IPAddress { get; }
    
    internal NetSocket(Socket socket)
    {
        IPAddress = (socket.RemoteEndPoint as IPEndPoint)!.Address.ToString();
    }
}