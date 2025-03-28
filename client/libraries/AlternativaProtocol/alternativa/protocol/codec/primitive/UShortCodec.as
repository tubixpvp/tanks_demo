package alternativa.protocol.codec.primitive {
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.NullMap;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	/**
	 * Кодек short
	 */	
	public class UShortCodec extends AbstractCodec {
	
		public function UShortCodec() {
			nullValue = int.MIN_VALUE;
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return reader.readUnsignedShort();
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			//dest.writeShort(int(object));
			throw new Error("Unsigned short encoding is not implemented on Flash");
		}

	}
}