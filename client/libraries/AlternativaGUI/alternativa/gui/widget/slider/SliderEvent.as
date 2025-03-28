package alternativa.gui.widget.slider {
	import flash.events.Event;
	
	public class SliderEvent extends Event {
		
		public static const START_DRAG:String = "SliderEventStartDrag";
		public static const STOP_DRAG:String = "SliderEventStopDrag";
		public static const CHANGE_POS:String = "SliderEventChangePos";
		public var pos:int;
		
		public function SliderEvent(type:String, pos:int) {
			super(type, true, true);
			this.pos = pos;
		}
	
	}
}