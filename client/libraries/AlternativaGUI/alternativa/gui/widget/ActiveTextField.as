package alternativa.gui.widget {
	import alternativa.iointerfaces.focus.IFocus;
	import alternativa.gui.init.GUI;
	import alternativa.iointerfaces.mouse.ICursorActive;
	import alternativa.iointerfaces.mouse.ICursorActiveListener;
	
	import flash.text.TextField;
	
	public class ActiveTextField extends TextField implements IFocus, ICursorActive, ICursorActiveListener {
		
		/**
		 * Флаг фокусировки на объекте (устанавливается, если tabEnabled)
		 */		
		private var _focused:Boolean;
		/**
		 * Флаг фокусировки на ком-то из детей
		 */	
		protected var _childFocused:Boolean;
		
		/**
		 * Подписчики на события курсора 
		 */		
		private var _cursorListeners:Array;
		/**
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
		 * Флаг наведения курсора 
		 */		
		protected var _over:Boolean;
		/**
		 * Флаг нажатия 
		 */		
		protected var _pressed:Boolean;
		/**
		 * Флаг блокировки 
		 */		
		protected var _locked:Boolean;
		/**
		 * Хинт 
		 */		
		protected var _hint:String;
		
		
		public function ActiveTextField() {
			super();
			// Инициализация фокуса
			tabEnabled = true;
			// Инициализация событий курсора
			_cursorActive = true;
			_cursorListeners = new Array();
			addCursorListener(this);
			//if (IOInterfaces.mouseAvailable) {
				_cursorOverType = GUI.mouseManager.cursorTypes.NONE;
				_cursorPressedType = GUI.mouseManager.cursorTypes.NONE;
			/*} else {
				_cursorOverType = 1;
				_cursorPressedType = 1;
			}*/
			// Инициализация флагов состояний
			_over = false;
			_pressed = false;
			_locked = false;
			_focused = false;
		}
		
		/**
		 * Установка флага фокусировки
		 */	
		public function set focused(value:Boolean):void {
			_focused = value;
		}
		/**
		 * Получить флаг фокусировки
		 * @return флаг фокусировки
		 */		
		public function get focused():Boolean {
			return _focused;
		}
		
		/**
		 * Установка флага фокусировки (при фокусировке на ком-то из детей)
		 */	
		public function set childFocused(value:Boolean):void {
			_childFocused = value;
		}
		/**
		 * Получить флаг фокусировки (на ком-то из детей)
		 * @return флаг фокусировки
		 */		
		public function get childFocused():Boolean {
			return _childFocused;
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
		 * Получить список слушателей событий курсора
		 * @return 
		 * 
		 */		
		public function get cursorListeners():Array {
			return _cursorListeners;
		}
		
		/**
		 * Включить/отключить рассылку событий 
		 * @param value - флаг рассылки событий
		 */		
		public function set cursorActive(value:Boolean):void {
			_cursorActive = value;
		}
		
		/**
		 * Получить значение флага рассылки событий 
		 * @return флаг рассылки событий
		 * 
		 */		
		public function get cursorActive():Boolean {
			return _cursorActive;
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
		 * Задать строку подсказки 
		 * @param value строка подсказки
		 * 
		 */		
		public function set hint(value:String):void {
			_hint = value;
		}
		/**
		 * Текст всплывающей подсказки
		 */		 
		public function get hint():String {
			return _hint;
		}
		
		//----- ICursorActiveListener
		/**
		 * Рассылка одинарного щелчка
		 * (через некоторое время после mouseDown)
		 */		
		public function click():void {}
		/**
		 * Рассылка двойного щелчка
		 * (по второму подряд mouseDown)
		 */		
		public function doubleClick():void {}
		/**
		 * Рассылка вращения колёсика мыши 
		 * @param delta поворот
		 */		
		public function mouseWheel(delta:int):void {}	
		/**
		 *  Установка флага наведения
		 */ 
		public function set over(value:Boolean):void {
			_over = value;
		}
		/**
		 *  Установка флага нажатия
		 */ 
		public function set pressed(value:Boolean):void {
			_pressed = value;
		}
		/**
		 * Установка флага блокировки
		 */		
		public function set locked(value:Boolean):void {
			_locked = value;
			cursorActive = !value;
			mouseEnabled = !value;
			if (value)
				_over = false;
		}
		/**
		 * Получить флаг наведения
		 * @return флаг наведения
		 * 
		 */		
		public function get over():Boolean {
			return _over;
		}
		/**
		 * Получить флаг наведения
		 * @return флаг наведения
		 * 
		 */	
		public function get pressed():Boolean {
			return _pressed;
		}
		/**
		 * Получить флаг блокировки
		 * @return флаг блокировки
		 * 
		 */		
		public function get locked():Boolean {
			return _locked;
		}

	}
}