package alternativa.gui.chat {
	import alternativa.gui.layout.enums.Align;
	import alternativa.gui.widget.Text;
	
	
	public class ChatListItemMessage extends Text {
		
		public function ChatListItemMessage(text:String = "", color:int = -1) {
			super(200, text, Align.LEFT, true, false, 255, color);
		}
		
		/**
		 * Определение класса для скинования
		 * @return класс для скинования
		 */		
		override protected function getSkinType():Class {
			return ChatListItemMessage;
		}

	}
}