package alternativa.protocol.codec {
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	/**
	 * Интерфейс кодека. 
	 */	
	public interface ICodec	{
		/**
		 * Кодирует объект.
		 * 
		 * @param dest объект для записи
		 * @param object кодируемый объект
		 * @param nullmap карта null-ов на заполнение
		 */		
		function encode(dest:IDataOutput, object:Object, nullmap:NullMap, notnull:Boolean):void;
		/**
		 * Декодирует объект.
		 * 
		 * @param reader объект для чтения
		 * @param nullmap карта null-ов
		 * 
		 * @return разкодированный объект
		 */		
		function decode(reader:IDataInput, nullmap:NullMap, notnull:Boolean):Object;
		
	}
}