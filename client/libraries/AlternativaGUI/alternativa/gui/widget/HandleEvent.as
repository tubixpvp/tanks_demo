package alternativa.gui.widget {
	import alternativa.gui.widget.slider.SliderEvent;
	
	public class HandleEvent extends SliderEvent {
		
		public static const START_DRAG:String = "HandleEventStartDrag";
		public static const STOP_DRAG:String = "HandleEventStopDrag";
		public static const CHANGE_POS:String = "HandleEventChangePos";
		
		public function HandleEvent(type:String, pos:int) {
			super(type, pos);
		}

	}
}