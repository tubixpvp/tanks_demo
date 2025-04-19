package alternativa.gui.chat {
	import flash.events.Event;
	
	public class ChatEvent extends Event {

		/**
		 * @eventType sendMessage
		 */
		public static const SEND_MESSAGE:String = "sendMessage";
		
		public var text:String;
		
		public function ChatEvent(type:String, text:String) {
			super(type, true, true);
			this.text = text;
		}
	}
}