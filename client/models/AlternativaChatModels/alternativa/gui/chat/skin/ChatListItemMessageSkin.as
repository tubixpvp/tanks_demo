package alternativa.gui.chat.skin {
	import alternativa.gui.skin.widget.TextSkin;
	
	import flash.text.TextFormat;
	
	public class ChatListItemMessageSkin extends TextSkin {
		
		private static const tfNormal:TextFormat = new TextFormat("Alternativa", 11, 0xffffff);
		private static const tfLocked:TextFormat = new TextFormat("Alternativa", 11, 0x898972);
		
		private static const thickness:Number = -100;
		private static const sharpness:Number = 100;
		
		public function ChatListItemMessageSkin() {
			super(ChatListItemMessageSkin.tfNormal,
				  ChatListItemMessageSkin.tfLocked,
				  ChatListItemMessageSkin.thickness,
				  ChatListItemMessageSkin.sharpness);
			
		}

	}
}