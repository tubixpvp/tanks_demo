package alternativa.network {
	import alternativa.protocol.Packet;
	import alternativa.protocol.Protocol;
	
	import flash.errors.*;
	import flash.events.*;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	/**
	 * Канал приема-передачи команд
	 */	
	public class CommandSocket extends Socket implements ICommandSender {
		
		/**
		 * Упаковщик в пакеты 
		 */		
		private var packet:Packet;
		/**
		 * Протокол данных 
		 */
		private var protocol:Protocol;
		/**
		 * Обработчик команд 
		 */	    
		private var handler:ICommandHandler;
		/**
		 * Буфер для чтения из сети 
		 */	    
		private var dataBuffer:ByteArray;
		/**
		 * Указатель на начало текущего пакета 
		 */	    
		private var packetCursor:int;
		
		public var console:Object;
		
		/**
		 * @param host ip или url (без "http://") для подключения
		 * @param port номер порта для подключения
		 * @param packet упаковщик в пакеты 
		 * @param protocol протокол данных 
		 * @param handler обработчик команд 
		 */		
		public function CommandSocket(host:String, port:uint, packet:Packet, protocol:Protocol, handler:ICommandHandler) {
			super();
			this.packet = packet;
			this.protocol = protocol;
			this.handler = handler;
			handler.commandSender = this;
			dataBuffer = new ByteArray();
			packetCursor = 0;
			
			configureListeners();
		}
		
		/**
		 * Отправить команду
		 * @param command команда
		 * @param zipped флаг принудительного сжатия (в случае false сжимается только при больших пакетах)
		 */		
		public function sendCommand(command:Object, zipped:Boolean = false):void {
			//trace("sendCommand " + this);
			//try {
				var encoded:ByteArray = new ByteArray();
				protocol.encode(encoded, command);
				encoded.position = 0;
				
				/*console.write("CommandSocket sendCommand encoded bytes", 0xff0000);
				while (encoded.bytesAvailable) {
					console.write("		" + encoded.readByte(), 0x666666);
				}
				encoded.position = 0;*/
				
				if (zipped) {
					packet.wrapZippedPacket(encoded, this);
				} else {
					packet.wrapUnzippedPacket(encoded, this);
				}
				flush();
			//} catch (error:Error) {
			//	trace("sendCommand error: " + error + " " + this);
			//}
		}
		
		/**
		 * Добавление обработчиков событий
		 */		
		private function configureListeners():void {
			addEventListener(Event.CLOSE, closeHandler);
			addEventListener(Event.CONNECT, connectHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}
		
		/**
		 * Обработка открытия соединения
		 * @param event событие открытия соединения 
		 */		
		private function connectHandler(event:Event):void {
			// Рассылка события
			//trace("connectHandler event: " + event + " " + this);
			handler.open();
		}
		
		/**
		 * Обработка закрытия соединения
		 * @param event событие закрытия соединения 
		 */
		private function closeHandler(event:Event):void {
			// Рассылка события
			//trace("closeHandler event: " + event);
			handler.close();
		}
		 
		/**
		 * Прием данных
		 * @param event событие готовности данных для считывания
		 */		
		private function socketDataHandler(event:ProgressEvent):void {
			dataBuffer.position = dataBuffer.length;
			while (bytesAvailable > 0) {
				dataBuffer.writeByte(readByte());
			}
			dataBuffer.position = packetCursor;
			var readBuffer:Boolean = Boolean(dataBuffer.bytesAvailable);
			while (readBuffer) {
				// Распаковка
				var unwrappedData:ByteArray = new ByteArray();
				var unwrapped:Boolean = packet.unwrapPacket(dataBuffer, unwrappedData);
				// Если пакет считан полностью и распакован, декодируем
				if (unwrapped) {
					unwrappedData.position = 0;
					var decodedData:Object = protocol.decode(unwrappedData);
					
					// Запуск обработки команды
					handler.executeCommand(decodedData);
					
					// Если вычитали все пакеты, сбрасываем буфер чтения
					if (dataBuffer.bytesAvailable == 0) {
						dataBuffer = new ByteArray();
						packetCursor = 0;
						readBuffer = false;
					} else {
						packetCursor = dataBuffer.position;
					}
				} else {
					readBuffer = false;
				}
			}
		}
		
		/**
		 * Обработка ошибок ввода-вывода
		 * @param event событие ошибки ввода-вывода
		 */		
		private function ioErrorHandler(event:IOErrorEvent):void {
			throw new Error(event.toString());
		}
		
		/**
		 * Обработка ошибок безопасности
		 * @param event событие ошибки безопасности
		 */		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			throw new Error(event.toString());
		}
		
	}
}