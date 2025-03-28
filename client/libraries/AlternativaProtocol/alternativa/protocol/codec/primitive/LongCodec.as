package alternativa.protocol.codec.primitive {
	import alternativa.protocol.codec.AbstractCodec;
	import alternativa.protocol.codec.NullMap;
	import alternativa.types.Long;
	import alternativa.types.LongFactory;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	
	public class LongCodec extends AbstractCodec {
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		override protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return LongFactory.getLong(reader.readInt(), reader.readInt());
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		override protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			dest.writeInt(Long(object).high);
			dest.writeInt(Long(object).low);
		}

	}
}