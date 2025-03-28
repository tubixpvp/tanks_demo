package alternativa.protocol.codec.complex {
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.NullMap;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * Абстрактный кодек для строк
	 */	
	public class StringCodec extends AbstractCodec {
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			var length:int = LengthCodec.decodeLength(reader);
			return reader.readUTFBytes(length);
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			var bytes:ByteArray = new ByteArray();
		   	bytes.writeUTFBytes(String(object));
		   	var length:int = bytes.length;
		   	// записываем длину
		   	LengthCodec.encodeLength(dest, length);
		   	dest.writeBytes(bytes, 0, length);
		}

	}
}