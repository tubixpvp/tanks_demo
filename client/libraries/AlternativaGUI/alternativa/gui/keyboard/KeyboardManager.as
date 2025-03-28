package alternativa.gui.keyboard {
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.init.GUI;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	/**
	 * Менеджер клавиатуры 
	 */	
	public class KeyboardManager extends Sprite implements IKeyboardManager {
		
		/**
		 * Нажатые клавиши
		 */		
		private var _pressedKeys:Array;
		
		/**
		 * Подписчики на события клавиатуры
		 */		
		private var keyboardListeners:Array;
		
		
		public function KeyboardManager() {}
		
		/**
		 * Инициализация (в том числе регистрация в IOInterfaces)
		 */		
		public function init(container:DisplayObjectContainer):void {
			//IOInterfaces.registerKeyboardManager(this);
			
			container.addChild(this);
			
			_pressedKeys = new Array();
			keyboardListeners = new Array();
			
			container.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEvent);
			container.addEventListener(KeyboardEvent.KEY_UP, onKeyEvent);
		}
		
		/**
		 * Добавить слушателя событий клавиатуры
		 * @param listener слушатель
		 */		
		public function addKeyboardListener(listener:IKeyboardListener):void {
			keyboardListeners.push(listener);
		}
		/**
		 * Удалить слушателя событий клавиатуры
		 * @param listener слушатель
		 */		
		public function removeKeyboardListener(listener:IKeyboardListener):void {
			keyboardListeners.splice(keyboardListeners.indexOf(listener), 1);
		}
		
		/**
		 * Проверка фильтров заданного объекта и его фильтров его детей
		 * @return список детей, для которых надо тоже проверить фильтры
		 */			
		private function checkFilters(testObject:DisplayObject, e:KeyboardEvent):Array {
			var children:Array = new Array();
			// Проверяем горячие клавиши самого объекта
			if (testObject is IKeyboardListener && keyboardListeners.indexOf(IKeyboardListener(testObject)) == -1) {
				var listener:IKeyboardListener = IKeyboardListener(testObject);
				var filters:Array;
				var functions:Array;
				if (e.type == KeyboardEvent.KEY_DOWN) {
					filters = listener.keyFiltersConfig.keyDownFilters;
					for (var j:int = 0; j < filters.length; j++) {
						var filter:IKeyFilter = IKeyFilter(filters[j]);
						if (filter.filter(e)) {
							functions = listener.keyFiltersConfig.getKeyDownFunctions(e.keyCode, filter);
							for (var k:int = 0; k < functions.length; k++) {
								var f:BindedFunction = BindedFunction(functions[k]);
								f.func.apply(f.object, f.args);
							}
							return null;
						}
					}
				} else {
					filters = listener.keyFiltersConfig.keyUpFilters;
					for (j = 0; j < filters.length; j++) {
						var filter:IKeyFilter = IKeyFilter(filters[j]);
						if (filter.filter(e)) {
							functions = listener.keyFiltersConfig.getKeyUpFunctions(e.keyCode, filter);
							for (var k:int = 0; k < functions.length; k++) {
								var f:BindedFunction = BindedFunction(functions[k]);
								f.func.apply(f.object, f.args);
							}
							return null;
						}
					}
				}
				// Составляем список детей объекта для проверки
				if (listener.keyFiltersConfig.childrenKeysAvailable) {
					children = listener.keyFiltersConfig.activeChildren;
				}
			} else {
				
			}
			return children;
		}
		
		/**
		 * Обработка события клавиатуры
		 * @param e событие клавиатуры
		 */		
		private function onKeyEvent(e:KeyboardEvent):void {
			// Сохранение клавиш 
			if (e.type == KeyboardEvent.KEY_DOWN) {
				if (_pressedKeys.indexOf(e.keyCode) == -1) {
					_pressedKeys.push(e.keyCode);
				}
			} else {
				_pressedKeys.splice(_pressedKeys.indexOf(e.keyCode), 1);
			}
			
			// Рассылка события подписчикам
			for (var i:int = 0; i < keyboardListeners.length; i++) {
				var listener:IKeyboardListener = IKeyboardListener(keyboardListeners[i]);
				var filters:Array;
				var functions:Array;
				if (e.type == KeyboardEvent.KEY_DOWN) {
					filters = listener.keyFiltersConfig.keyDownFilters;
					for (var j:int = 0; j < filters.length; j++) {
						var filter:IKeyFilter = IKeyFilter(filters[j]);
						if (filter.filter(e)) {
							functions = listener.keyFiltersConfig.getKeyDownFunctions(e.keyCode, filter);
							for (var k:int = 0; k < functions.length; k++) {
								var f:BindedFunction = BindedFunction(functions[k]);
								f.func.apply(f.object, f.args);
							}
						}
					}
				} else {
					filters = listener.keyFiltersConfig.keyUpFilters;
					for (j = 0; j < filters.length; j++) {
						var filter:IKeyFilter = IKeyFilter(filters[j]);
						if (filter.filter(e)) {
							functions = listener.keyFiltersConfig.getKeyUpFunctions(e.keyCode, filter);
							for (var k:int = 0; k < functions.length; k++) {
								var f:BindedFunction = BindedFunction(functions[k]);
								f.func.apply(f.object, f.args);
							}
						}
					}
				}
			}
			
			// Объект, на котором установлен фокус
			var focused:IFocus = GUI.focusManager.focused;
			// Проверка фильтров горячих клавиш
			if (focused != null) {
				var testObject:DisplayObject = DisplayObject(focused);
				var excludeObject:DisplayObject;
				var testList:Array = new Array();
				var children:Array = new Array();
				
				while (testObject != null) {
					// Перебираем детей
					testList = checkFilters(testObject, e);
					// Проверка на завершение фильтрации (нашли сработавший объект)
					if (testList == null) return;
					
					// Тестовые объекты - дети текущего тестового объекта
					while (testList.length > 0) {
						// Проверяем детей и составляем следующий список тестовых объектов
						for (var i:int = 0; i < testList.length; i++) {
							if (DisplayObject(testList[i]) != excludeObject) {
								var tempArr:Array = checkFilters(testList[i], e);
								// Проверка на завершение фильтрации (нашли сработавший объект)
								if (tempArr == null) return;
								// Сохраняем детей для которых надо провести проверку
								for (var j:int = 0; j < tempArr.length; j++) {
									children.push(tempArr[j]);
								}
							}
						}
						// Теперь дети - тестовые объекты
						testList = new Array();
						for (var i:int = 0; i < children.length; i++) {
							testList.push(children[i]);
						}
						children = new Array();
					}
					// Поднимаемся на уровень по иерархии
					excludeObject = testObject;
					/*if (testObject is WindowBase)
						testObject = null;
					else
						testObject = testObject.parent;*/
					testObject = testObject.parent;
				}
			}
		}
		
		/**
		 * Список кодов нажатых клавиш
		 */		
		public function get pressedKeys():Array {
			return _pressedKeys;
		}
		
	}
}