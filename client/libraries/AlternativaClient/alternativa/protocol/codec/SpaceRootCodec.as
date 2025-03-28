package alternativa.protocol.codec {
	import alternativa.init.Main;
	import alternativa.network.command.SpaceCommand;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.protocol.type.Byte;
	import alternativa.types.Long;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	public class SpaceRootCodec extends AbstractCodec {
		
		private var codecFactory:ICodecFactory;
		
		public function SpaceRootCodec(codecFactory:ICodecFactory) {
			super();
			this.codecFactory = codecFactory;
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			 return new Array(reader, nullmap);
	    }
	    
	    /**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
		   	if (object is ByteArray) {
		   		Main.writeToConsole("encode produce hash");
		   		var hash:ByteArray = object as ByteArray;
		   		
		   		var byteCodec:ICodec = codecFactory.getCodec(Byte);
		   		
		   		byteCodec.encode(dest, int(0), nullmap, true);
		   		hash.position = 0;
		   		for (var i:int = 0; i < 32; i++) {
		   			byteCodec.encode(dest, hash.readByte(), nullmap, true);
		   		}
		   	} else {
		   		Main.writeToConsole("encode SpaceCommand");
		   		Main.writeToConsole("   objectId: " + c.objectId);
		   		Main.writeToConsole("   methodId: " + c.methodId);
		   		var c:SpaceCommand = SpaceCommand(object);
		   		
		   		var longCodec:ICodec = codecFactory.getCodec(Long);
		   		longCodec.encode(dest, c.objectId, nullmap, true);
		   		longCodec.encode(dest, c.methodId, nullmap, true);
		   		
		   		ByteArray(c.params).position = 0;
		   		while (ByteArray(c.params).bytesAvailable) {
		   			dest.writeByte(c.params.readByte());
		   		}
		   		c.nullMap.reset();
		   		for (i = 0; i < c.nullMap.getSize(); i++) {
		   			nullmap.addBit(c.nullMap.getNextBit());
		   		}
		   	}
	    }

	}
}