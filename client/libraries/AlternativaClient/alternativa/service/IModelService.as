package alternativa.service {
	import alternativa.model.IModel;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.types.Long;
	
	import flash.utils.IDataInput;
	
	
	public interface IModelService {
		
		/**
		 * Регистрирует метод модели. Вызывается базовой библиотекой модели при инициализации. 
		 * 
		 * @param modelId идентификатор модели, метод которой регистрируется
		 * @param methodId идентификатор регистрируемого метода
		 */
		function register(modelId:Long, methodId:Long):void;
		
		/**
		 * Регистрирует новую модель поведения.
		 * 
		 * @param modelInstance экземпляр регистрируемой модели
		 * @param interfaces список интерфейсов, реализуемых моделью
		 */
		function add(modelInstance:IModel, interfaces:Array):void;
		
		/**
		 * Удаляет регистрацию модели поведения.
		 * 
		 * @param modelId идентификатор модели, для которого удаляется информация
		 */
		function remove(modelId:Long):void;
		
		/**
		 * Вызывает метод модели для указанного объекта.
		 *  
		 * @param clientObject объект, для которого выполняется вызов
		 * @param methodId идентификатор вызываемого метода
		 * @param params
		 * @param nullMap
		 */
		function invoke(clientObject:ClientObject, methodId:Long, params:IDataInput, nullMap:NullMap):void;
		
		/**
		 * Возвращает экземпляр модели по её идентификатору.
		 * 
		 * @param id идентификатор модели
		 * @return экземпляр модели с заданным идентификатором
		 */
		function getModel(id:Long):IModel;
		
		/**
		 * Возвращает список моделей, реализующих заданный интерфейс.
		 * 
		 * @param modelInterface интерфейс модели
		 * 
		 * @return массив, содержащий список моделей, реализующих заданный интерфейс
		 */
		function getModelsByInterface(modelInterface:Class):Array;
		
		/**
		 * Возвращает модель указанного объекта, реализующую заданный интерфейс.
		 *  
		 * @param object объект, модель которого запрашивается
		 * @param modelInterface интерфейс модели
		 * @return модель объекта, реализующая заданный интерфейс
		 * @throws Error при наличии более одной подходящей модели 
		 */
		function getModelForObject(object:ClientObject, modelInterface:Class):IModel;
		
		/**
		 * Возвращает список моделей указанного объекта, реализующих заданный интерфейс.
		 *  
		 * @param object объект, модели которого запрашивается
		 * @param modelInterface интерфейс моделей
		 * @return список моделей объекта, реализующих заданный интерфейс
		 */		
		function getModelsForObject(object:ClientObject, modelInterface:Class):Array;
		
	}
}