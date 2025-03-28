package alternativa.protocol.codec {
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * Кодек, различающий null 
	 */	
	public class AbstractCodec implements ICodec {
		
		protected var nullValue:Object = null;
		
		/**
		 * Кодировать объект
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 * @param nullmap карта null-ов на заполнение
		 */		
		public function encode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			if (!notnull) {
				nullmap.addBit(object == nullValue);
			}
			// не null
			if (object != nullValue) {
				doEncode(dest, object, nullmap, notnull);
			} else {
				if (notnull) {
					throw new Error("Object is null, but notnull expected.");
				}
			}
		}
			
		/**
		 * Декодировать объект
		 * @param reader объект для чтения
		 * @param nullmap карта null-ов
		 * @return разкодированный объект
		 */		
		public function decode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			return (!notnull && nullmap.getNextBit()) ? nullValue : doDecode(reader, nullmap, notnull);
		}
		
		/**
		 * Реализация декодирования объекта
		 * @param reader объект для чтения
		 * @return разкодированный объект
		 */		
		protected function doDecode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object {
			throw new Error("Method not implementated.");
		}
		
		/**
		 * Реализация кодирования объекта
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 */		
		protected function doEncode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void {
			throw new Error("Method not implementated.");
		}
		
	}
}