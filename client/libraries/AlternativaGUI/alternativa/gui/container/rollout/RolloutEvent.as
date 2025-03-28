package alternativa.gui.container.rollout {
	import flash.events.Event;
		
	public class RolloutEvent extends Event {
		
		//public static const SELECT:String = "RolloutEventSelect";
		public static const MINIMIZE:String = "RolloutEventMimimize";
		public static const MAXIMIZE:String = "RolloutEventMaximize";
		public static const CLOSE:String = "RolloutEventClose";
		//public static const TITLE_CHANGE:String = "RolloutEventTitleChange";
		
		public var rollout:Rollout;
		
		public function RolloutEvent(type:String, rollout:Rollout) {
			super(type, true, true);
			this.rollout = rollout;
		}

	}
}