package alternativa.gui.widget.button {
	import flash.events.Event;
	
	public class ButtonEvent extends Event {
		
		public static const PRESS:String = "ButtonEventPress";
		public static const EXPRESS:String = "ButtonEventExpress";
		public static const CLICK:String = "ButtonEventClick";
		
		public var button:IButton;
		
		public function ButtonEvent(type:String, button:IButton) {
			super(type, true, true);
			this.button = button;
		}
		
	}
}