package alternativa.object {
	import alternativa.model.IModel;
	import alternativa.network.ICommandHandler;
	import alternativa.register.ObjectRegister;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	/**
	 * Клиентский объект.
	 */
	public class ClientObject {
		/**
		 * Имя объекта.
		 */		
		private var _name:String;
		/**
		 * Идентификатор объекта.
		 */
		private var _id:Long;
		/**
		 * Родительский объект.
		 */		
		private var _parent:ClientObject;
		/**
		 * Список моделей.
		 */
		private var models:Array;
		/**
		 * Параметры сервера.
		 */
		private var serverParams:Dictionary;
		/**
		 * Параметры моделей поведения объекта. Ключами являются классы моделей, к которым относятся параметры.
		 */
		private var runtimeParams:Dictionary;
		/**
		 * Обработчик команд спейса, в котором находится объект.
		 */
		private var _handler:ICommandHandler;
		/**
		 * Реестр объектов, содержащий данный объект.
		 */		
		private var _register:ObjectRegister;
		
		/**
		 * Создаёт новый клиентский объект.
		 * 
		 * @param id идентификатор объекта
		 * @param parent родительский объект
		 * @param name имя объекта
		 * @param handler обработчик команд
		 * @param models список моделей объекта
		 * @param params параметры инициализации
		 */
		public function ClientObject(id:Long, parent:ClientObject, name:String, handler:ICommandHandler, models:Array = null, params:Dictionary = null) {
			_id = id;
			_parent = parent;
			_name = name;
			_handler = handler;
			if (models != null) {
				this.models = models;
			} else {
				this.models = new Array();
			}
			if (params != null) {
				serverParams = params;
			} else {
				serverParams = new Dictionary();
			}
			runtimeParams = new Dictionary();
		}
		
		/**
		 * Добавляет объекту модель поведения.
		 * 
		 * @param model модель поведения
		 */
		public function addModel(model:IModel):void {
			models.push(model.id);
		}
		
		/**
		 * Удаляет модель поведения у объекта.
		 * 
		 * @param model удаляемая модель поведения
		 */
		public function removeModel(model:IModel):void {
			var index:int = models.indexOf(model.id);
			models.splice(index, 1);
		}
		
		/**
		 * Возвращает параметры указанной модели поведения.
		 *  
		 * @param model класс модели поведения, параметры которой запрашиваются
		 * 
		 * @return объект, представляющий параметры указанной модели поведения
		 */
		public function getParams(model:Class):Object {
			return runtimeParams[model];
		}
		
		/**
		 * Устанавливает параметры указанной модели поведения.
		 * 
		 * @param model класс модели поведения, параметры которой устанавливаются
		 * @param params объект, представляющий параметры модели поведения
		 */		
		public function putParams(model:Class, params:Object):void {
			runtimeParams[model] = params;
		}		
		
		/**
		 * Идентификатор объекта.
		 */
		public function get id():Long {
			return _id;
		}
		
		/**
		 * Родительский объект.
		 */
		public function get parent():ClientObject {
			return _parent;
		}
		
		/**
		 * Обработчик команд спейса, которому принадлежит объект.
		 */
		public function get handler():ICommandHandler {
			return _handler;
		}
		
		/**
		 * Возвращает список моделей поведения объекта.
		 * 
		 * @return массив, содержащий список моделей поведения объекта
		 */
		public function getModels():Array {
			return models;
		}
		
		public function get register():ObjectRegister {
			return _register;
		}

		public function set register(value:ObjectRegister):void {
			_register = value;
		}

	}
}