package alternativa.init {
	import alternativa.iointerfaces.keyboard.IKeyboardManager;
	import alternativa.iointerfaces.keyboard.KeyboardManager;
	import alternativa.osgi.bundle.IBundleActivator;
	
	
	public class AlternativaKeyboardManager implements IBundleActivator {
		
		public function start(osgi:alternativa.init.OSGi):void
		{
			// менеджер клавиатуры
			var keyboardManager:IKeyboardManager = new KeyboardManager();
			keyboardManager.init(Main.mainContainer);
		}

		public function stop(osgi:alternativa.init.OSGi):void
		{
		}
	}
}