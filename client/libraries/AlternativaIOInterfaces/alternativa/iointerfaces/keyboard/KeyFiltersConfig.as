package alternativa.iointerfaces.keyboard {
	import flash.utils.Dictionary;
	
	/**
	 * Конфигурация фильтров и функций,
	 * вызываемых по нажатию и отжатию клавиш клавиатуры 
	 */
	public class KeyFiltersConfig {
		
		/**
		 * Фильтры, срабатывающие по нажатию
		 */		
		private var _keyDownFilters:Array;
		
		/**
		 * Фильтры, срабатывающие по отжатию
		 */
		private var _keyUpFilters:Array;
		
		/**
		 * Дествия, прикрепленные к нажатию клавиши и фильтру
		 */		
		private var keyDownActions:Dictionary;
		
		/**
		 * Дествия, прикрепленные к отжатию клавиши и фильтру
		 */		
		private var keyUpActions:Dictionary;
		
		/**
		 * Функции, прикрепленные к действиям по нажатию 
		 */		
		private var keyDownActionFunctions:Dictionary;
		
		/**
		 * Функции, прикрепленные к действиям по отжатию
		 */		
		private var keyUpActionFunctions:Dictionary;
		
		private var _childrenKeysAvailable:Boolean;
		/**
		 * Список потомков, слушающих клавиатуру
		 */		
		private var _activeChildren:Array;
		
		
		public function KeyFiltersConfig() {
			_keyDownFilters = new Array();
			_keyUpFilters = new Array();
			
			keyDownActions = new Dictionary(false);
			keyUpActions = new Dictionary(false);
			
			keyDownActionFunctions = new Dictionary(false);
			keyUpActionFunctions = new Dictionary(false);
			
			_childrenKeysAvailable = false;
			_activeChildren = new Array();
		}
		
		/**
		 * Добавление фильтра клавиш, срабатывающего по нажатию
		 * @param filter фильтр клавиш
		 * @param action название действия, связанного с фильтром
		 */		
		public function addKeyDownFilter(filter:IKeyFilter, action:String):void {
			if (filter != null && action != null && action != "") {
				// Добавляем в список фильтров
				_keyDownFilters.push(filter);
				// Добавляем в список действий
				keyDownActions[filter] = action;
			}
		}
		/**
		 * Удаление фильтра клавиш, срабатывающего по нажатию
		 * @param filter фильтр клавиш
		 */		
		public function removeKeyDownFilter(filter:IKeyFilter):void {
			if (filter != null) {
				// Удаляем из списка действий
				keyDownActions[filter] = null;
				// Удаляем из списка фильтров
				_keyDownFilters.splice(_keyDownFilters.indexOf(filter), 1);
			}
		}
		/**
		 * Добавление действия по отжатию клавиши
		 * @param action название действия
		 * @param filter фильтр клавиши
		 */	
		public function addKeyUpFilter(filter:IKeyFilter, action:String):void {
			if (filter != null && action != null && action != "") {
				// Добавляем в список фильтров
				_keyUpFilters.push(filter);
				// Добавляем в список действий
				keyUpActions[filter] = action;
			}
		}
		/**
		 * Удаление действия по отжатию клавиши
		 * @param filter фильтр клавиши
		 */	
		public function removeKeyUpFilter(filter:IKeyFilter):void {
			if (filter != null) {
				// Удаляем из списка действий
				keyUpActions[filter] = null;
				// Удаляем из списка фильтров
				_keyUpFilters.splice(_keyUpFilters.indexOf(filter), 1);
			}
		}
		
		/**
		 * Прикрепить вызов функции к действию по нажатию 
		 * @param action действие
		 * @param object объект, в котором вызывается функция
		 * @param func вызываемая функция
		 * @param args параметры вызываемой функции
		 */		
		public function bindKeyDownAction(action:String, object:Object, func:Function, ...args):void {
			if (keyDownActionFunctions[action] == null) {
				keyDownActionFunctions[action] = new Array();
			}
			keyDownActionFunctions[action].push(new BindedFunction(object, func, args));
		}
		/**
		 * Открепить функцию от действия по нажатию 
		 * @param action действие
		 * @param object объект, в котором вызывается функция
		 * @param func вызываемая функция
		 */		
		public function unbindKeyDownAction(action:String, object:Object, func:Function):void {
			var functions:Array = keyDownActionFunctions[action];
			for (var i:int = 0; i < functions.length; i++) {
				if (BindedFunction(functions[i]).object == object && BindedFunction(functions[i]).func == func) {
					functions.splice(i, 1);
				}
			}
		}
		
		/**
		 * Прикрепить вызов функции к действию по отжатию
		 * @param action действие
		 * @param object объект, в котором вызывается функция
		 * @param func вызываемая функция
		 * @param args параметры вызываемой функции
		 */
		public function bindKeyUpAction(action:String, object:Object, func:Function, ...args):void {
			if (keyUpActionFunctions[action] == null) {
				keyUpActionFunctions[action] = new Array();
			}
			keyUpActionFunctions[action].push(new BindedFunction(object, func, args));
		}
		/**
		 * Открепить функцию от действия по отжатию
		 * @param action действие
		 * @param object объект, в котором вызывается функция
		 * @param func вызываемая функция
		 */
		public function unbindKeyUpAction(action:String, object:Object, func:Function):void {
			var functions:Array = keyUpActionFunctions[action];
			for (var i:int = 0; i < functions.length; i++) {
				if (BindedFunction(functions[i]).object == object && BindedFunction(functions[i]).func == func) {
					functions.splice(i, 1);
				}
			}
		}
		
		/**
		 * Список фильтров, срабатывающих по нажатию
		 */		
		public function get keyDownFilters():Array {
			return _keyDownFilters;
		}
		/**
		 * Список фильтров, срабатывающих по отжатию
		 */		
		public function get keyUpFilters():Array {
			return _keyUpFilters;
		}
		
		/**
		 * Получить список функций, вызываемых для сработавшего по нажатию фильтра
		 * @param code код клавиши
		 * @param filter фильтр 
		 * @return список функций
		 */		
		public function getKeyDownFunctions(code:uint, filter:IKeyFilter):Array {
			var functions:Array;
			var action:String = keyDownActions[filter];
			if (action != null) {
				functions = keyDownActionFunctions[action];
			} else {
				functions = new Array();
			}
			return functions;
		}
		/**
		 * Получить список функций, вызываемых для сработавшего по отжатию фильтра
		 * @param code код клавиши
		 * @param filter фильтр 
		 * @return список функций
		 */	
		public function getKeyUpFunctions(code:uint, filter:IKeyFilter):Array {
			var functions:Array;
			var action:String = keyUpActions[filter];
			if (action != null) {
				functions = keyUpActionFunctions[action];
			} else {
				functions = new Array();
			}
			return functions;
		}
		
		/**
		 * Добавить потомка по графической иерархии в список активных
		 * (если сам объект в фокусе и childrenKeysAvailable,
		 * то могут срабатывать фильтры клавиш активных потомков) 
		 * @param child потомок по графической иерархии
		 */		
		public function addActiveChild(child:IKeyboardListener):void {
			_activeChildren.push(child);
		}
		/**
		 * Удалить потомка по графической иерархии из списка активных
		 * @param child потомок по графической иерархии
		 */		
		public function removeActiveChild(child:IKeyboardListener):void {
			_activeChildren.splice(_activeChildren.indexOf(child), 1);
		}
		
		/**
		 * Срабатывание горячих клавиш потомков
		 */		
		public function get childrenKeysAvailable():Boolean {
			return _childrenKeysAvailable;
		}
		public function set childrenKeysAvailable(value:Boolean):void {
			_childrenKeysAvailable = value;
		}
		
		/**
		 * Список потомков, слушающих клавиатуру
		 */		
		public function get activeChildren():Array {
			return _activeChildren;
		}
		
	}
}