package alternativa.gui.init {	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import alternativa.osgi.bundle.IBundleActivator;
	import alternativa.init.OSGi;
	import alternativa.init.IOInterfaces;
	import alternativa.iointerfaces.mouse.IMouseManager;
	import alternativa.iointerfaces.keyboard.IKeyboardManager;
	import alternativa.iointerfaces.focus.IFocusManager;
	
	
	public class GUI implements IBundleActivator {
		
		public static var mouseManager:IMouseManager;
		public static var keyboardManager:IKeyboardManager;
		public static var focusManager:IFocusManager;

		public function start(osgi:OSGi) : void
		{
			mouseManager = IOInterfaces.mouseManager;
			keyboardManager = IOInterfaces.keyboardManager;
			focusManager = IOInterfaces.focusManager;
		}
		public function stop(osgi:OSGi) : void
		{
		}

	}
}