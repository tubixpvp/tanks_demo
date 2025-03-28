package alternativa.protocol.codec {
	import alternativa.init.Main;
	import alternativa.network.command.ControlCommand;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.protocol.type.Byte;
	import alternativa.resource.ResourceInfo;
	import alternativa.types.Long;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * Корневой кодек канала управления. Разбирает входные данные на команды и кодирует исходящие команды.
	 */
	public class ControlRootCodec extends AbstractCodec {
		
		private var codecFactory:ICodecFactory;
		
		public function ControlRootCodec(codecFactory:ICodecFactory) {
			super();
			this.codecFactory = codecFactory;
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			var commands:Array = new Array();
			var params:Array = new Array();
			
			while (reader.bytesAvailable) {
				var commandId:int = int(codecFactory.getCodec(Byte).decode(reader, nullmap, true));
				
				Main.writeToConsole("decode ControlCommand");
			   	Main.writeToConsole("   id: " + commandId);
				
				switch (commandId) {
					case ControlCommand.HASH_RESPONCE:
						var hash:ByteArray = new ByteArray();
						for (var i:int = 0; i < 32; i++) {
							hash.writeByte(int(codecFactory.getCodec(Byte).decode(reader, nullmap, true)));
						}
						hash.position = 0;
						commands.push(hash);
						break;	
					case ControlCommand.OPEN_SPACE:
						commands.push(new ControlCommand(ControlCommand.OPEN_SPACE, "openSpace", new Array()));
						break;
					case ControlCommand.LOAD_RESOURCE:
						// processId
						params.push(int(codecFactory.getCodec(int).decode(reader, nullmap, true)));
						
						var arrayCodec:ICodec = codecFactory.getArrayCodec(ResourceInfo, true, 2);
						params.push(arrayCodec.decode(reader, nullmap, true) as Array);
						
						commands.push(new ControlCommand(ControlCommand.LOAD_RESOURCE, "loadResources", params));
						break;
					case ControlCommand.UNLOAD_RESOURCES:	
						arrayCodec = codecFactory.getArrayCodec(Long, true, 1);
						// resource id array
						params.push(arrayCodec.decode(reader, nullmap, true) as Array);
						// resource version array
						params.push(arrayCodec.decode(reader, nullmap, true) as Array);
						commands.push(new ControlCommand(ControlCommand.UNLOAD_RESOURCES, "unloadResources", params));
						break;
					case ControlCommand.COMMAND_REQUEST:
						params.push(String(codecFactory.getCodec(String).decode(reader, nullmap, true)));
						commands.push(new ControlCommand(ControlCommand.COMMAND_REQUEST, "commandRequest", params));
						break;
					case ControlCommand.SERVER_MESSAGE:
						// type
						params.push(int(codecFactory.getCodec(int).decode(reader, nullmap, true)));
						// message
						params.push(String(codecFactory.getCodec(String).decode(reader, nullmap, true)));
						commands.push(new ControlCommand(ControlCommand.SERVER_MESSAGE, "serverMessage", params));
						break;
				}
			}
			return commands;
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			var c:ControlCommand = ControlCommand(object);
			var byteCodec:ICodec = codecFactory.getCodec(Byte);
			
			Main.writeToConsole("encode ControlCommand");
		   	Main.writeToConsole("   id: " + c.id);
			
			byteCodec.encode(dest, c.id, nullmap, true);
			switch (c.id) {
				case ControlCommand.HASH_REQUEST:
					//byteCodec.encode(dest, int(1), nullmap, true);
					break;
				case ControlCommand.HASH_ACCEPT:
					//byteCodec.encode(dest, int(4), nullmap, true);
					break;
				case ControlCommand.RESOURCE_LOADED:
					codecFactory.getCodec(int).encode(dest, int(c.params[0]), nullmap, true);
					break;
				case ControlCommand.LOG:
					codecFactory.getCodec(int).encode(dest, int(c.params[0]), nullmap, true);
					codecFactory.getCodec(String).encode(dest, String(c.params[1]), nullmap, true);
					break;
				case ControlCommand.COMMAND_RESPONCE:
					codecFactory.getCodec(String).encode(dest, String(c.params[0]), nullmap, true);
					break;
			}
		}

	}
}