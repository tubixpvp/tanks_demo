package alternativa.gui.chat {
	import flash.events.Event;
	
	/**
	 * Выбран пользователь в чате
	 */
	public class ChatUserSelectEvent extends Event {
		
		public var userId:Number;

		public static const TYPE:String = "ChatUserSelectEvent";
		
		public function ChatUserSelectEvent(userId:Number) {
			super(ChatUserSelectEvent.TYPE, true, true);
			this.userId = userId;
		}
	}
}