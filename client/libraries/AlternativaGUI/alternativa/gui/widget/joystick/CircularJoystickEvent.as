package alternativa.gui.widget.joystick {
	import flash.events.Event;
	import flash.geom.Point;
	
	public class CircularJoystickEvent extends Event {
		
		public static const START_DRAG:String = "CircularJoystickEventStartDrag";
		public static const STOP_DRAG:String = "CircularJoystickEventStopDrag";
		public static const CHANGE_POS:String = "CircularJoystickEventChangePos";
		
		public var offsetValue:Point;
		public var angleValue:Number;
		public var radiusValue:Number;
		
		public function CircularJoystickEvent(type:String, offsetValue:Point, angleValue:Number, radiusValue:Number)	{
			super(type, true, true);
			this.offsetValue = offsetValue;
			this.angleValue = angleValue;
			this.radiusValue = radiusValue;
		}

	}
}