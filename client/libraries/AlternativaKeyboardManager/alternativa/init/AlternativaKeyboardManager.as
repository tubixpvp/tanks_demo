package alternativa.init {
	import alternativa.iointerfaces.keyboard.IKeyboardManager;
	import alternativa.iointerfaces.keyboard.KeyboardManager;
	
	
	public class AlternativaKeyboardManager {
		
		public static function init():void {
			// менеджер клавиатуры
			var keyboardManager:IKeyboardManager = new KeyboardManager();
			keyboardManager.init(Main.mainContainer);
		}

	}
}