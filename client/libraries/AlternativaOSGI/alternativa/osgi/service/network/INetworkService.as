package alternativa.osgi.service.network {
	
	public interface INetworkService {
		
		function get server():String;
		
		function get port():int;
		
		function get resourcesPath():String;
		
	}
}