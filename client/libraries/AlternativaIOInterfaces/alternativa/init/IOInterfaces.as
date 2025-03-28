package alternativa.init {
	import alternativa.iointerfaces.focus.FocusManager;
	import alternativa.iointerfaces.focus.IFocusManager;
	import alternativa.iointerfaces.keyboard.IKeyboardManager;
	import alternativa.iointerfaces.mouse.IMouseManager;
	
	import flash.display.Stage;
	
	/**
	 * Интерфейсы ввода вывода
	 */	
	public class IOInterfaces {
		
		/**
		 * Менеджер мыши
		 */		
		private static var _mouseManager:IMouseManager;
		/**
		 * Наличие менеджера мыши
		 */		
		private static var _mouseAvailable:Boolean = false;
		/**
		 * Менеджер клавиатуры
		 */		
		private static var _keyboardManager:IKeyboardManager;
		/**
		 * Наличие менеджера клавиатуры
		 */		
		private static var _keyboardAvailable:Boolean = false;
		/**
		 * Менеджер фокусировки
		 */		
		private static var _focusManager:IFocusManager;
		/**
		 * Сцена 
		 */		
		private static var _stage:Stage;
		
		
		/**
		 * Инициализация
		 * @param stage сцена
		 */		
		public static function initStage(stage:Stage):void {
			_stage = stage;
			if (_focusManager != null) {
				_focusManager.init(_stage);
			}
		}
		
		/**
		 * Регистрация менеджера мыши
		 * @param manager менеджер мыши
		 */		
		public static function registerMouseManager(manager:IMouseManager):void {
			_mouseManager = manager;
			_mouseAvailable = true;
			if (_focusManager == null) {
				_focusManager = new FocusManager();
				if (_stage != null) {
					_focusManager.init(_stage);
				}
			}
		}
		
		/**
		 * Регистрация менеджера клавиатуры
		 * @param manager менеджер клавиатуры
		 */		
		public static function registerKeyboardManager(manager:IKeyboardManager):void {
			_keyboardManager = manager;
			_keyboardAvailable = true;
			if (_focusManager == null) {
				_focusManager = new FocusManager();
				if (_stage != null) {
					_focusManager.init(_stage);
				}
			}
		}
		
		/**
		 * Наличие менеджера мыши
		 */		
		public static function get mouseAvailable():Boolean {
			return _mouseAvailable;
		}
		
		/**
		 * Наличие менеджера клавиатуры
		 */
		public static function get keyboardAvailable():Boolean {
			return _keyboardAvailable;
		}
		
		/**
		 * Менеджер фокусировки
		 */		
		public static function get focusManager():IFocusManager {
			return _focusManager;
		}
		
		/**
		 * Менеджер мыши
		 */		
		public static function get mouseManager():IMouseManager {
			return _mouseManager;
		}
		
		/**
		 * Менеджер клавиатуры
		 */		
		public static function get keyboardManager():IKeyboardManager {
			return _keyboardManager;
		}

	}
}