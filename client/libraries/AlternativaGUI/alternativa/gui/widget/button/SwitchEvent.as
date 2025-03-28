package alternativa.gui.widget.button {
	
	public class SwitchEvent extends ButtonEvent {
		
		public static const START_DRAG:String = "SwitchEventStartDrag";
		public static const STOP_DRAG:String = "SwitchEventStopDrag";
		public static const NEXT:String = "SwitchEventNext";
		public static const PREV:String = "SwitchEventPrev";
		
		public function SwitchEvent(type:String, button:SwitchButton) {
			super(type, button);
		}

	}
}