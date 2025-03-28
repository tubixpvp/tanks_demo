package alternativa.gui.window {
	import flash.events.Event;
	
	public class WindowEvent extends Event {
		
		public static const SELECT:String = "WindowEventSelect";
		public static const UNSELECT:String = "WindowEventUnselect";
		public static const MINIMIZE:String = "WindowEventMimimize";
		public static const MAXIMIZE:String = "WindowEventMaximize";
		public static const RESTORE:String = "WindowEventRestore";
		public static const CLOSE:String = "WindowEventClose";
		
		public var window:WindowBase;
		
		public function WindowEvent(type:String, window:WindowBase) {
			super(type, true, true);
			this.window = window;
		}
	
	}
}