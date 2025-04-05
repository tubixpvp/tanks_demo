package alternativa.protocol.codec.primitive {
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.NullMap;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	public class UIntCodec extends AbstractCodec {
		
		public function UIntCodec() {
			nullValue = int.MIN_VALUE;
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return reader.readUnsignedInt();
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			dest.writeUnsignedInt(uint(object));
		}

	}
}