package alternativa.protocol.factory {
	import alternativa.protocol.codec.ICodec;
	
	
	/**
	 * Интерфейс фабрики кодеков
	 */	
	public interface ICodecFactory {
		
		/**
		 * Регистрация кодека
		 * @param targetClass класс
		 * @param codec кодек
		 */		
		function registerCodec(targetClass:Class, codec:ICodec):void;
		
		/**
	     * Получить кодек для класса
	     * @param targetClass класс
	     * @return кодек
	     */
	    function getCodec(targetClass:Class):ICodec;
		
	    /**
	     * Получить кодек для массива
	     * @param targetClass класс элемента
	     * @param depth уровень вложенности 
	     * @return кодекs
	     */		
	    function getArrayCodec(targetClass:Class, elementnotnull:Boolean = true, depth:int = 1):ICodec;
	    
	}
}