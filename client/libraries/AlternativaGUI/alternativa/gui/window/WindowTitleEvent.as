package alternativa.gui.window {
	import flash.events.Event;
	
	public class WindowTitleEvent extends Event {
		
		public static const SELECT:String = "WindowTitleEventSelect";
		public static const MINIMIZE:String = "WindowTitleEventMimimize";
		public static const MAXIMIZE:String = "WindowTitleEventMaximize";
		public static const RESTORE:String = "WindowTitleEventRestore";
		public static const CLOSE:String = "WindowTitleEventClose";
		
		public function WindowTitleEvent(type:String) {
			super(type, true, true);
		}
	
	}
}