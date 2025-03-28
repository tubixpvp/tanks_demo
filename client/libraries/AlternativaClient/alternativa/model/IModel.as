package alternativa.model {
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.protocol.factory.ICodecFactory;
	import alternativa.types.Long;
	
	import flash.utils.IDataInput;
	
	/**
	 * Интерфейс модели поведения.
	 */
	public interface IModel	{
		
		/**
		 * Инициализирует модель для заданного объекта.
		 * 
		 * @param clientObject объект, для которого инициализируется модель
		 * @param codecFactory фабрика кодеков, используемых при инициализации
		 * @param dataInput данные для инициализации модели
		 * @param nullMap карта null-значений в передаваемых данных
		 */
		function _initObject(clientObject:ClientObject, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void;
		
		
		/**
		 * Применяет заданный метод модели поведения к указанному объекту.
		 *  
		 * @param clientObject объект, к которому применяется метод модели
		 * @param methodId идентификатор метода модели
		 * @param codecFactory фабрика кодеков, используемых в методах модели
		 * @param dataInput входные параметры вызываемого метода
		 * @param nullMap карта null-значений во входных параметрах
		 */
		function invoke(clientObject:ClientObject, methodId:Long, codecFactory:ICodecFactory, dataInput:IDataInput, nullMap:NullMap):void;
		
		/**
		 * Идентификатор модели.
		 */
		function get id():Long;
		
	}
}