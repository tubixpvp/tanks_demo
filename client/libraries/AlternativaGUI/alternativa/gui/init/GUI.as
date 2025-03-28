package alternativa.gui.init {
	import alternativa.gui.focus.FocusManager;
	import alternativa.gui.keyboard.KeyboardManager;
	import alternativa.gui.mouse.MouseManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	
	public class GUI {
		
		public static var mouseManager:MouseManager;
		public static var keyboardManager:KeyboardManager;
		public static var focusManager:FocusManager;
		
		public static function init(stage:Stage, GUIcursorEnabled:Boolean = false, cursorContainer:DisplayObjectContainer = null) {
			
			// инициализация мыши
			mouseManager = new MouseManager();
			mouseManager.init(stage, GUIcursorEnabled, cursorContainer);
			
			// инициализация клавиатуры
			keyboardManager = new KeyboardManager();
			keyboardManager.init(stage);
			
			// инициализация фокуса
			focusManager = new FocusManager();
			focusManager.init(stage);
		}

	}
}