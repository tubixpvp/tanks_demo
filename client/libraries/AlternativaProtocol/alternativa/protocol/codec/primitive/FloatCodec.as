package alternativa.protocol.codec.primitive {
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.NullMap;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	public class FloatCodec extends AbstractCodec {
		
		public function FloatCodec() {
			nullValue = Number.NEGATIVE_INFINITY;
		}
		
	     /**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return reader.readFloat();
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			dest.writeFloat(Number(object));
		}

	}
}