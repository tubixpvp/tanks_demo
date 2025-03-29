package alternativa.gui.base {
	import alternativa.gui.focus.IFocus;
	import alternativa.gui.init.GUI;
	import alternativa.gui.keyboard.IKeyboardListener;
	import alternativa.gui.keyboard.KeyFiltersConfig;
	import alternativa.gui.mouse.ICursorActive;
	import alternativa.gui.mouse.ICursorActiveListener;
	
	/**
	 * Базовый интерактивный объект
	 */	
	public class ActiveObject extends GUIObject implements IFocus, ICursorActive, ICursorActiveListener, IKeyboardListener {
		
		/**
		 * @private
		 * Флаг фокусировки на объекте (устанавливается, если tabEnabled)
		 */		
		protected var _focused:Boolean;
		/**
		 * @private
		 * Флаг фокусировки на ком-то из детей
		 */	
		protected var _childFocused:Boolean;
		
		/**
		 * @private
		 * Подписчики на события курсора 
		 */		
		private var _cursorListeners:Array;
		/**
		 * @private
		 * Флаг включения/выключения приема событий курсора 
		 */		
		private var _cursorActive:Boolean;
		/**
		 * Внешний вид курсора при наведении на объект
		 */		
		private var _cursorOverType:uint;
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */		
		private var _cursorPressedType:uint;
		
		/**
		 * @private
		 * Флаг наведения курсора 
		 */		
		protected var _over:Boolean;
		/**
		 * @private
		 * Флаг нажатия 
		 */		
		protected var _pressed:Boolean;
		/**
		 * @private
		 * Флаг блокировки 
		 */		
		protected var _locked:Boolean;
		/**
		 * @private
		 * Хинт 
		 */		
		protected var _hint:String;
		
		/**
		 * @private
		 * Конфигурация фильтров клавиатуры 
		 */		
		private var _keyFiltersConfig:KeyFiltersConfig;
		
		
		public function ActiveObject() {
			super();
			// Инициализация фокуса
			tabEnabled = true;
			// Инициализация событий курсора
			_cursorActive = true;
			_cursorListeners = new Array();
			addCursorListener(this);
			//if (IOInterfaces.mouseAvailable) {
				_cursorOverType = GUI.mouseManager.cursorTypes.ACTIVE;
				_cursorPressedType = GUI.mouseManager.cursorTypes.ACTIVE;
			/*} else {
				_cursorOverType = 1;
				_cursorPressedType = 1;
			}*/
			// Инициализация событий клавиатуры 
			_keyFiltersConfig = new KeyFiltersConfig();
			// Инициализация флагов состояний
			_over = false;
			_pressed = false;
			_locked = false;
			_focused = false;
			_childFocused = false;
		}
		
		//----- IFocused
		/**
		 * Флаг фокусировки
		 */		
		public function get focused():Boolean {
			return _focused;
		}
		public function set focused(value:Boolean):void {
			if (_focused != value) {
				_focused = value;
				if (_focused) {
					focus();
				} else {
					unfocus();
				}
			}
		}
			
		/**
		 * Флаг фокусировки (на ком-то из детей)
		 */		
		public function get childFocused():Boolean {
			return _childFocused;
		}
		public function set childFocused(value:Boolean):void {
			if (_childFocused != value) {
				_childFocused = value;
				/*if (_childFocused) {
					focus();
				} else {
					unfocus();
				}*/
			}
		}
		
		/**
		 * Фокусировка
		 */		
		protected function focus():void {}
		/**
		 * Расфокусировка
		 */		
		protected function unfocus():void {}
		
		//----- ICursorActive
		/**
		 * Добавить слушателя событий курсора 
		 * @param listener слушатель событий курсора 
		 */		
		public function addCursorListener(listener:ICursorActiveListener):void {
			if (_cursorListeners.indexOf(listener) == -1) {
				_cursorListeners.push(listener);
			}
		}
		/**
		 * Удалить слушателя событий курсора 
		 * @param listener слушатель событий курсора 
		 */		
		public function removeCursorListener(listener:ICursorActiveListener):void {
			var index:int = _cursorListeners.indexOf(listener);
			if (index != -1) {
				_cursorListeners.splice(index, 1);
			}
		}
		
		/**
		 * Список слушателей событий курсора
		 */		
		public function get cursorListeners():Array {
			return _cursorListeners;
		}
		
		/**
		 * Флаг получения событий курсора
		 */		
		public function get cursorActive():Boolean {
			return _cursorActive;
		}
		public function set cursorActive(value:Boolean):void {
			_cursorActive = value;
		}
		
		/**
		 * Внешний вид курсора при наведении на объект
		 */
		public function get cursorOverType():uint {
			return _cursorOverType;
		}
		public function set cursorOverType(type:uint):void {
			_cursorOverType = type;
		}
		
		/**
		 * Внешний вид курсора при нажатии на объект или наведении на нажатый объект
		 */
		public function get cursorPressedType():uint {
			return _cursorPressedType;
		}
		public function set cursorPressedType(type:uint):void {
			_cursorPressedType = type;
		}
			
		/**
		 * Текст всплывающей подсказки
		 */		 
		public function get hint():String {
			return _hint;
		}
		public function set hint(value:String):void {
			_hint = value;
		}
		
		//----- ICursorActiveListener
		/**
		 * Рассылка одинарного щелчка
		 */		
		public function click():void {}
		/**
		 * Рассылка двойного щелчка
		 * (по второму подряд mouseDown)
		 */		
		public function doubleClick():void {}		
		 
		/**
		 * Флаг наведения
		 */		
		public function get over():Boolean {
			return _over;
		}
		public function set over(value:Boolean):void {
			_over = value;
		}
		
		/**
		 * Флаг нажатия
		 */	
		public function get pressed():Boolean {
			return _pressed;
		}
		public function set pressed(value:Boolean):void {
			_pressed = value;
		}
		
		/**
		 * Флаг блокировки
		 */		
		public function get locked():Boolean {
			return _locked;
		}
		public function set locked(value:Boolean):void {
			_locked = value;
			if (value)
				_over = false;
		}
		
		//----- IKeyboardListener
		/**
		 * Конфигурация фильтров и функций,
		 * вызываемых по нажатию и отжатию клавиш клавиатуры 
		 */		
		public function get keyFiltersConfig():KeyFiltersConfig {
			return _keyFiltersConfig;
		}

	}
}