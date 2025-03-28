package alternativa.register {
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	
	
	/**
	 * Клиентский класс.
	 */	
	public class ClientClass {
		
		/**
		 * Имя класса.
		 */		
		private var _name:String;
		/**
		 * Идентификатор класса.
		 */
		private var _id:Long;
		/**
		 * Родительский класс.
		 */		
		private var _parent:ClientClass;
		/**
		 * Классы наследники.
		 */		
		private var _children:Array;
		/**
		 * Список моделей поведения.
		 */
		private var _models:Array;
		/**
		 * Параметры моделей поведения.
		 */
		private var _modelsParams:Dictionary;
		
		
		/**
		 * @param id идентификатор объекта
		 * @param parent родительский класс
		 * @param name имя класса
		 * @param modelsToAdd список моделей поведения для добавления
		 * @param modelsToRemove список моделей поведения для удаления
		 * @param modelsParams параметры для моделей поведения
		 */		
		public function ClientClass(id:Long, parent:ClientClass, name:String, models:Array = null, modelsParams:Dictionary = null) {
			_id = id;
			_parent = parent;
			_name = name;
			
			if (models != null) {
				_models = models;
			} else {
				_models = new Array();
			}
			if (modelsParams != null) {
				_modelsParams = modelsParams;
			} else {
				_modelsParams = new Dictionary();
			}
		}
		
		public function addChild(child:ClientClass):void {
			_children.push(child);
		}
		public function removeChild(child:ClientClass):void {
			_children.splice(_children.indexOf(child), 1);
		}
		
		/**
		 * Идентификатор класса.
		 */
		public function get id():Long {
			return _id;
		}
		
		/**
		 * Родительский класс.
		 */
		public function get parent():ClientClass {
			return _parent;
		}
		
		/**
		 * Классы наследники.
		 */
		public function get children():Array {
			return _children;
		}

		/**
		 * Имя класса.
		 */
		public function get name():String {
			return _name;
		}
		
		/**
		 * Список моделей поведения. 
		 */		
		public function get models():Array {
			return _models;
		}
		
		/**
		 * Параметры моделей поведения. 
		 */		
		public function get modelsParams():Dictionary {
			return _modelsParams;
		}

	}
}