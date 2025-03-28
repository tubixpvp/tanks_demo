package alternativa.osgi.service.network {
	
	public class NetworkService implements INetworkService {
		
		private var _server:String;
		private var _port:int;
		private var _resourcesPath:String;
		
		public function NetworkService(server:String, port:int, resourcesPath:String) {
			_server = server;
			_port = port;
			_resourcesPath = resourcesPath;
		}
		
		public function get server():String {
			return _server;
		}
		
		public function get port():int {
			return _port;
		}
		
		public function get resourcesPath():String {
			return _resourcesPath;
		}

	}
}