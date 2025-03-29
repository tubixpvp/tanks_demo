package alternativa.gui.base {
	import alternativa.gui.init.GUI;
	import alternativa.gui.keyboard.IKeyboardListener;
	import alternativa.gui.keyboard.KeyFiltersConfig;
	import alternativa.gui.mouse.ICursorActive;
	import alternativa.gui.mouse.ICursorActiveListener;
	
	/**
	 * Облегченный интерактивный объект на основе <code>Shape</code>
	 */
	public class ActiveShapeObject extends GUIShapeObject implements ICursorActive, ICursorActiveListener, IKeyboardListener {
		
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
		
		
		public function ActiveShapeObject()	{
			super();
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
		}
		
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
		 * Cписок слушателей событий курсора
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