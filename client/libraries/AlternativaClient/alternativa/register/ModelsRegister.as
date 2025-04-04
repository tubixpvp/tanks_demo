package alternativa.register {
	import alternativa.init.Main;
	import alternativa.model.IModel;
	import alternativa.object.ClientObject;
	import alternativa.protocol.codec.NullMap;
	import alternativa.service.IModelService;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	import flash.utils.IDataInput;
	
	/**
	 * Реестр моделей. 
	 */	
	public class ModelsRegister implements IModelService {
		
		/**
		 * Список экземпляров моделей (modelId - modelInstance) 
		 */		
		private var modelInstances:Dictionary;
		/**
		 * Список экземпляров моделей. Ключами являются интерфейсы, значениями -- массивы, содержащие список экземпляров моделей, реализующих интерфейс.
		 */		
		private var modelInstancesByInterface:Dictionary;
		/**
		 * Список интерфейсов моделей (modelId - modelInterface) 
		 */
		private var modelInterfaces:Dictionary;
		/**
		 * Список соответствий методов и моделей (methodId - modelId) 
		 */		
		private var modelByMethod:Dictionary;
		
		/**
		 * 
		 */
		public function ModelsRegister() {
			modelInterfaces = new Dictionary();
			modelInstances = new Dictionary();
			modelByMethod = new Dictionary();
			modelInstancesByInterface = new Dictionary();
		}
		
		/**
		 * Регистрирует метод модели. Вызывается базовой библиотекой модели при инициализации. 
		 * 
		 * @param modelId идентификатор модели, метод которой регистрируется
		 * @param methodId идентификатор регистрируемого метода
		 */
		public function register(modelId:Long, methodId:Long):void {
			modelByMethod[methodId] = modelId;
			Main.writeToConsole("Метод " + methodId + " (модель " + modelId + ") зарегистрирован", 0x009999);
		}
		
		/**
		 * Регистрирует новую модель поведения.
		 * 
		 * @param modelInstance экземпляр регистрируемой модели
		 * @param interfaces список интерфейсов, реализуемых моделью
		 */
		public function add(modelInstance:IModel, interfaces:Array):void {
			var modelId:Long = modelInstance.id;
			modelInstances[modelId] = modelInstance;
			modelInterfaces[modelId] = interfaces;
			for (var i:int = 0; i < modelInterfaces.length; i++) {
				var key:Class = Class(modelInterfaces[i]);
				var record:Array = modelInstancesByInterface[key];
				if (record == null) {
					modelInstancesByInterface[key] = record = new Array();
				}
				record.push(modelInstance);
			}
			Main.writeToConsole("Реализация модели " + modelId + " " + modelInstance +" добавлена в реестр", 0x009999);
		}
		
		/**
		 * Удаляет регистрацию модели поведения.
		 * 
		 * @param modelId идентификатор модели, для которого удаляется информация
		 */
		public function remove(modelId:Long):void {
			// Удаляем записи из мапы methodId => model
			for (var methodId:* in modelByMethod) {
				var id:Long = modelByMethod[methodId];
				if (id == modelId) {
					delete modelByMethod[methodId];
				}
			}
			// Удаляем модель из списков моделей интерфейсов
			var instance:IModel = IModel(modelInstances[modelId]);
			var interfaces:Array = modelInterfaces[modelId] as Array;
			for (var i:int = 0; i < interfaces.length; i++) {
				var key:Class = interfaces[i];
				var modelsArray:Array = modelInstancesByInterface[key] as Array;
				var index:int = modelsArray.indexOf(instance);
				modelsArray.splice(index, 1);
			}
			delete modelInterfaces[modelId];
			delete modelInstances[modelId];
			Main.writeToConsole("Реализация модели " + modelId + " удалена из реестра", 0x009999);
		}
		
		/**
		 * Вызывает метод модели для указанного объекта.
		 *  
		 * @param clientObject объект, для которого выполняется вызов
		 * @param methodId идентификатор вызываемого метода
		 * @param params
		 * @param nullMap
		 */
		public function invoke(clientObject:ClientObject, methodId:Long, params:IDataInput, nullMap:NullMap):void {
			var modelId:Long = Long(modelByMethod[methodId]);
			var model:IModel = IModel(modelInstances[modelId]);
			
			Main.writeToConsole(" ");
			Main.writeToConsole("ModelsRegister invoke methodId: " + methodId, 0x0000ff);
			Main.writeToConsole("ModelsRegister invoke clientObjectId: " + clientObject.id, 0x0000ff);
			Main.writeToConsole("ModelsRegister invoke modelId: " + modelId, 0x0000ff);
			Main.writeToConsole("ModelsRegister invoke model: " + model, 0x0000ff);
			
			model.invoke(clientObject, methodId, Main.codecFactory, params, nullMap);
		}
		
		/**
		 * Возвращает экземпляр модели по её идентификатору.
		 * 
		 * @param id идентификатор модели
		 * @return экземпляр модели с заданным идентификатором
		 */
		public function getModel(id:Long):IModel {
			return modelInstances[id];
		}
		
		/**
		 * Возвращает список моделей, реализующих заданный интерфейс.
		 * 
		 * @param modelInterface интерфейс модели
		 * 
		 * @return массив, содержащий список моделей, реализующих заданный интерфейс
		 */
		public function getModelsByInterface(modelInterface:Class):Array {
			return modelInstancesByInterface[modelInterface];
		}		
		
		/**
		 * Возвращает модель указанного объекта, реализующую заданный интерфейс.
		 *  
		 * @param object объект, модель которого запрашивается
		 * @param modelInterface интерфейс модели
		 * @return модель объекта, реализующая заданный интерфейс
		 * @throws Error при наличии более одной подходящей модели 
		 */
		public function getModelForObject(object:ClientObject, modelInterface:Class):IModel {
			var model:IModel;
			var modelIds:Array = object.getModels();
			// Цикл по моделям объекта
			for (var i:int = 0; i < modelIds.length; i++) {
				var interfaces:Array = modelInterfaces[modelIds[i]] as Array;
				if (interfaces == null) {
					Main.writeToConsole("[ModelsRegister::getModelForObject] no interfaces found. Object: " + object.id + ", model: " + modelIds[i], 0xFF0000);
				}
				// Цикл по интерфейсам модели
				for (var n:int = 0; n < interfaces.length; n++) {
					if (interfaces[n] == modelInterface) {
						// Нашлась модель с заданным интерфейсом. Проверяем её уникальность
						if (model == null) {
							model = getModel(modelIds[i]);
						} else {
							throw new Error("ModelsRegister getModelForObject: Найдено несколько моделей с указанным интерфейсом.", 0xff0000);
						}
						// Выходим из цикла по интерфейсам
						break;
					}
				}
			}
			return model;
		}
		
		/**
		 * Возвращает список моделей указанного объекта, реализующих заданный интерфейс.
		 *  
		 * @param object объект, модели которого запрашивается
		 * @param modelInterface интерфейс моделей
		 * 
		 * @return список моделей объекта, реализующих заданный интерфейс
		 */		
		public function getModelsForObject(object:ClientObject, modelInterface:Class):Array {
			var result:Array = new Array(); // TODO: рассмотреть вариант возврата исходного массива вместо клона
			var modelId:Array = object.getModels();
			// Цикл по моделям объекта
			for (var i:int = 0; i < modelId.length; i++) {
				var interfaces:Array = modelInterfaces[modelId[i]] as Array;
				// Цикл по интерфейсам модели
				for (var n:int = 0; n < interfaces.length; n++) {
					if (interfaces[n] == modelInterface) {
						result.push(getModel(modelId[i]));
						break;
					}
				}
			}
			return result;
		}
		
	}
}