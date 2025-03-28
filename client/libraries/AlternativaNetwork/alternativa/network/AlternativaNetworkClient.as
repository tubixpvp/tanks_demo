package alternativa.network {
	import alternativa.protocol.Packet;
	import alternativa.protocol.Protocol;
	
	/**
	 * Сетевой клиент
	 * @author Bragin
	 */	
	public class AlternativaNetworkClient {
		
		/**
		 * Адрес сервера 
		 */		
		private var host:String;
		/**
		 * Порт для подключения 
		 */		
		private var port:int;
		/**
		 * Протокол данных
		 */		
		private var protocol:Protocol;
		/**
		 * Упаковщик в пакеты
		 */		
		private var packet:Packet;
		
		/**
		 * @param host ip или url (без "http://") для подключения
		 * @param port номер порта для подключения
		 * @param protocol протокол данных
		 * @param handlerFactory фабрика по выдаче обработчиков команд
		 */		
		public function AlternativaNetworkClient(host:String, port:int, protocol:Protocol) {
			this.host = host;
			this.port = port;
			this.protocol = protocol;
			packet = new Packet();
		}
		
		public function newConnection(handler:ICommandHandler):CommandSocket {
			//trace("AlternativaNetworkClient newConnection");
			var s:CommandSocket = new CommandSocket(host, port, packet, protocol, handler);
			s.connect(host, port);
			return s;
		}

	}
}