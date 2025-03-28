package alternativa.gui.widget.joystick {
	import flash.events.Event;
	
	
	public class CrossJoystickEvent extends Event {
		
		public static const LEFT:String = "CrossJoystickEventLeft";
		public static const TOP:String = "CrossJoystickEventTop";
		public static const RIGHT:String = "CrossJoystickEventRight";
		public static const BOTTOM:String = "CrossJoystickEventBottom";
		
		public function CrossJoystickEvent(type:String) {
			super(type, true, true);
		}

	}
}