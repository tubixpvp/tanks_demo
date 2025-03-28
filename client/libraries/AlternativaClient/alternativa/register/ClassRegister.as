package alternativa.register {
	import alternativa.service.IClassService;
	import alternativa.types.Long;
	
	import flash.utils.Dictionary;
	

	public class ClassRegister implements IClassService {
		
		/**
		 * Классы по id
		 */		
		private var _classes:Dictionary;
		/**
		 * Список классов
		 */		
		private var _classList:Array;

		
		public function ClassRegister() {
			_classList = new Array();
			_classes = new Dictionary();
		}
		
		/**
		 * Создание клиентского класса и его регистрация в реестре
		 * 
		 * @param id идентификатор класса
		 * @param parent родительский класс
		 * @param name имя класса
		 * @param modelsToAdd список моделей для добавления
		 * @param modelsToRemove список моделей для удаления
		 * @param modelsParams параметры моделей поведения
		 * @return клиентский класс новый класс
		 */		
		public function createClass(id:Long,
								 	parent:ClientClass,
								 	name:String,
								 	modelsToAdd:Array = null,
								 	modelsToRemove:Array = null,
								 	modelsParams:Dictionary = null):ClientClass {
			// Список моделей
			var models:Array = new Array();
			if (parent != null) {
				var parentModels:Array = parent.models;
				for (var i:int = 0; i < parentModels.length; i++) {
					if (modelsToRemove != null) {
						if (modelsToRemove.indexOf(parentModels[i]) == -1) {
							models.push(parentModels[i]);
						}
					} else {
						models.push(parentModels[i]);
					}
				}				
			}
			if (modelsToAdd != null) {
				for (i = 0; i < modelsToAdd.length; i++) {
					models.push(modelsToAdd[i]);
				}
			}
			// Параметры моделей
			var params:Dictionary;
			if (parent != null) {
				params = new Dictionary();
				var parentParams:Dictionary = parent.modelsParams;
				for (var modelId:* in parentParams) {
					if (modelsParams[modelId] == null) {
						params[modelId] = parentParams[modelId];
					} else {
						params[modelId] = modelsParams[modelId];
					}
				}
				for (modelId in modelsParams) {
					if (params[modelId] == null) {
						params[modelId] = modelsParams[modelId];
					}
				}
			} else {
				params = modelsParams;
			}
			var newClass:ClientClass = new ClientClass(id, parent, name, models, params);
			parent.addChild(newClass);
			
			// Сохранение класса
			_classes[id] = newClass;
			_classList.push(newClass);
			
			return newClass;
		}
		
		/**
		 * Удаление класса из реестра
		 * @param id идентификатор удаляемого класса
		 */		
		public function destroyClass(id:Long):void {
			_classList.splice(_classList.indexOf(_classes[id]), 1);
			_classes[id] = null;
		}
		
		public function get classes():Dictionary {
			return _classes;
		}
		
		public function get classList():Array {
			return _classList;
		}

	}
}